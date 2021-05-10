//
//  WorkoutCompletedViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 01/04/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import Firebase

class WorkoutCompletedViewModel {
    
    let userID = Auth.auth().currentUser!.uid
    var dataDidLoadClosure: (()->())?
    var updateLoadingStatusClosure: (()->())?
    
    var numberOfItems: Int {
        return data.count + 2
    }
    
    var timeToComplete : String!
    var averageRPE : Double!
    private var data : [[String:AnyObject]] = [] {
        didSet{
            self.dataDidLoadClosure?()
        }
    }
    var isLoading: Bool = false {
        didSet {
            self.updateLoadingStatusClosure?()
        }
    }
    
    init(time :String, rpe: Double){
        self.timeToComplete = time
        self.averageRPE = rpe
    }
    
    func fetchData(){
        self.isLoading = true
        self.data = [ ["image": UIImage(named: "clock_icon")!,
                      "title":"Time",
                      "data":self.timeToComplete!],
                     ["image": UIImage(named: "scores_icon")!,
                      "title":"Average RPE",
                      "data":self.averageRPE.description]] as [[String:AnyObject]]
        self.isLoading = false
    }
    
    
    // MARK: - Discover Stats
    func updateDiscoverStats(for workout: workout, with workoutRPE:Int, and time: Int){
        let completedRef = Database.database().reference().child("SavedWorkouts").child(workout.savedID)
        
        completedRef.runTransactionBlock { (currentData) -> TransactionResult in
            if var post = currentData.value as? [String:AnyObject]{
                var completes = post["NumberOfCompletes"] as? Int ?? 0
                var totalScore = post["TotalScore"] as? Int ?? 0
                var totalTime = post["TotalTime"] as? Int ?? 0
                completes += 1
                totalScore += workoutRPE
                totalTime += time
                post["NumberOfCompletes"] = completes as AnyObject
                post["TotalScore"] = totalScore as AnyObject
                post["TotalTime"] = totalTime as AnyObject
                currentData.value = post
                return TransactionResult.success(withValue: currentData)
            }
            return TransactionResult.success(withValue: currentData)
        } andCompletionBlock: { (error, committed, snapshot) in
            if let error = error{
                print(error.localizedDescription)
            }
        }
    }
    
    // MARK: - Update self stats
    func updateSelfScores(for workout: workout, with rpe:Int) {
        let scoreInfo = [workout.title!:rpe]
        let scoresRef = Database.database().reference().child("Scores")
        scoresRef.child(userID).childByAutoId().setValue(scoreInfo) { (error, snapshot) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    func updateNumberOfCompletes(){
        let ref = Database.database().reference().child("users").child(userID)
        ref.runTransactionBlock { (currentData) -> TransactionResult in
            if var userData = currentData.value as? [String:AnyObject]{
                var completes = userData["numberOfCompletes"] as? Int ?? 0
                completes += 1
                userData["numberOfCompletes"] = completes as AnyObject
                currentData.value = userData
                return TransactionResult.success(withValue: currentData)
            }
            return TransactionResult.success(withValue: currentData)
        } andCompletionBlock: { (error, committed, snapshot) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    func updateWorkload(with workout:workout, workload:Int, endTime : Double, time: Int){
        
        
        let workloadData = ["timeToComplete": time,
                            "rpe": workout.score!,
                            "endTime": endTime,
                            "workload": workload,
                            "workoutID": workout.workoutID!] as [String : Any]
        let ref = Database.database().reference().child("Workloads").child(self.userID).childByAutoId()
        ref.setValue(workloadData)
    }
    
    // MARK: - Update Coach stats
    func updateCoachScores(for workout: workout, with rpe:Int, to coach: String){
        let scoreInfo = [workout.title!:rpe]
        let scoresRef = Database.database().reference().child("Scores")
        scoresRef.child(coach).childByAutoId().setValue(scoreInfo) { (error, snapshot) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    func uploadActivityToCoaches(for workout: workout, with rpe:Int){
        
        LoadFollowers.returnCoaches(for: userID) { (coaches) in
            let actData = ["time":ServerValue.timestamp(),
                           "message":"\(ViewController.username!) completed the workout \(workout.title!).",
                           "type":"Workout Completed"] as [String:AnyObject]
            let actRef = Database.database().reference().child("Public Feed")
            for coach in coaches {
                // upload activity
                actRef.child(coach).childByAutoId().setValue(actData) { (error, snapshot) in
                    if let error = error {
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
    
    
    // MARK: - Post
    func uploadPost(with workout: workout, privacy isPrivate: Bool){
        
        let postRef = Database.database().reference().child("Posts").childByAutoId()
        let postSelfReferences = Database.database().reference().child("PostSelfReferences").child(self.userID)
        let postID = postRef.key!
        let timelineRef = Database.database().reference().child("Timeline")
        
        
        var exerciseData = ["title":workout.title!,
                            "completed":true,
                            "createdBy":workout.createdBy!,
                            "score":workout.score!,
                            "timeToComplete":workout.timeToComplete!,
                            "creatorID":workout.creatorID!,
                            "liveWorkout":workout.liveWorkout!,
                            "fromDiscover":workout.fromDiscover!] as [String : Any]
        
        if !workout.liveWorkout{
            exerciseData["savedID"] = workout.savedID as AnyObject
        }
        
        if let data = workout.exercises{
            exerciseData["exercises"] = data.map { ($0.toObject())} as AnyObject
        }
        
        let postData = ["type": "workout",
                        "posterID": self.userID,
                        "workoutID": workout.workoutID!,
                        "username": ViewController.username!,
                        "time": ServerValue.timestamp(),
                        "isPrivate" : isPrivate,
                        "exerciseData":exerciseData] as [String : Any]
        
        postRef.setValue(postData)
        postSelfReferences.child(postID).setValue(true)
        timelineRef.child(userID).child(postID).setValue(true)
        FirebaseAPI.shared().uploadActivity(with: .CompletedWorkout(workout.title!))
//        LoadFollowers.returnCoaches(for: userID) { (coaches) in
//            for coach in coaches {
//                timelineRef.child(coach).child(postID).setValue(true)
//            }
//        }
        LoadFollowers.returnFollowers(for: userID) { (followers) in
            for follower in followers {
                timelineRef.child(follower).child(postID).setValue(true)
            }
        } 
    }
    
    // MARK: - Complete Workout
    func completeWorkout(for workout:workout, with time:Int){
        let ref = Database.database().reference().child("Workouts").child(userID).child(workout.workoutID!)
        ref.runTransactionBlock { (currentData) -> TransactionResult in
            if var workoutData = currentData.value as? [String:AnyObject] {
                workoutData["completed"] = true as AnyObject
                workoutData["score"] = workout.score?.description as AnyObject
                workoutData["timeToComplete"] = time as AnyObject
                workoutData["workload"] = workout.workload as AnyObject
                currentData.value = workoutData
                return TransactionResult.success(withValue: currentData)
            }
            return TransactionResult.success(withValue: currentData)
        } andCompletionBlock: { (error, committed, snapshot) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    
    // MARK: - returning functions
    func getData(at indexPath:IndexPath) -> [String:AnyObject] {
        return data[indexPath.item]
    }
    
    
    
    
}
