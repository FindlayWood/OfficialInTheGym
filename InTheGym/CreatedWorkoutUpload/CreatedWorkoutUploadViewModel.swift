//
//  CreatedWorkoutUploadViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 08/04/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import Firebase

class CreatedWorkoutUploadViewModel {
    
    var updateLoadingStatusClosure:(()->())?
    var collectionReloaded:(()->())?
    var uploadedWorkout:(()->())?
    
    let userID = Auth.auth().currentUser!.uid
    let workoutRef = Database.database().reference().child("Workouts")
    
    var isLoading : Bool = false {
        didSet{
            updateLoadingStatusClosure?()
        }
    }
    
    var data : [[String:AnyObject]] = [] {
        didSet{
            collectionReloaded?()
        }
    }
    
    var numberOfItems : Int {
        return data.count
    }
    
    var groupMembers : [String]?
    
    var createdFor : String!
    var noOfExercises : Int!
    var groupBool : Bool!
    
    init(createdFor:String, noOfExercises:Int, group: Bool){
        self.createdFor = createdFor
        self.noOfExercises = noOfExercises
        self.groupBool = group
    }

    
    func fetchData(){
        self.isLoading = true
        
        var tempData = [
                     ["title":"Exercises",
                      "label":"\(noOfExercises!)"],
                     ["title":"Public",
                      "image":UIImage(named: "public_icon")!,
                      "description":"This workout is public. This means that it can be viewed by everyone and it may appear on the discover page. Tap to change."],
                     ["title":"Add to Saved",
                      "image":UIImage(named: "Workout Completed")!,
                      "description":"Adding this workout to your saved workouts where you can add it to your workouts in the future. We recommend this. Tap to change."],
                     ["title":"Add to Created",
                      "image":UIImage(named: "Workout Completed")!,
                      "description":"Adding this workout to your created workout list where you can add it to your workouts in the future. We recommend this. Tap to Change."],
                     ["title":"Post to Timeline",
                      "image":UIImage(named: "Workout Completed")!,
                      "description":"Posting this workout to the timeline. Your followers and players/coaches will be able to see this workout on the timeline. Tap to change."],
            ] as [[String:AnyObject]]
        
        
        if groupBool == true {
            UserIDToUser.groupIdToGroupName(groupID: createdFor) { (group) in
                let createdInsert = ["title":"Created For:",
                                     "label":group.groupTitle] as [String:AnyObject]
                tempData.insert(createdInsert, at: 0)
                self.data = tempData
                self.isLoading = false
            }

        } else {
            UserIDToUser.transform(userID: createdFor) { (user) in
                let createdInsert = ["title":"Created For:",
                                     "label":user.username!] as [String:AnyObject]
                tempData.insert(createdInsert, at: 0)
                self.data = tempData
                self.isLoading = false
            }
            
            
            
            
        }
    }
    func createGroupPost(with title:String){
        let postData = ["type":"Set Workout",
                        "username":ViewController.username!,
                        "message": "I have just set a new workout titled - \(title), for this group. It should be in your workouts.",
                        "time":ServerValue.timestamp()] as [String:AnyObject]
        let groupRef = Database.database().reference().child("GroupPosts").child(createdFor).childByAutoId()
        groupRef.setValue(postData)
    }
    
    func upload(with workout:workout, and stepCount:Int, savedID:String){
        
        FirebaseAPI.shared().uploadActivity(with: .CreatedWorkout(workout.title!))
        var createdWorkout = workout.toObject()
        createdWorkout["savedID"] = savedID as AnyObject
        
        if groupBool == true {
            
            createdWorkout["assigned"] = true as AnyObject
            // creating workout for group
            
            let groupRef = Database.database().reference().child("GroupMembers").child(createdFor)
            groupRef.observeSingleEvent(of: .value) { (snapshot) in
                for child in snapshot.children{
                    let memberID:String = (child as AnyObject).key
                    if memberID != self.userID {
                        for step in 1...stepCount{
                            
                            if step > 1{
                                createdWorkout["title"] = workout.title! + " \(step)" as AnyObject
                            }
                            let ref = self.workoutRef.child(memberID).childByAutoId()
                            ref.setValue(createdWorkout)
                        }
                        let notification = NotificationNewWorkout(from: self.userID, to: memberID, workoutID: workout.workoutID!)
                        let uploadNotification = NotificationManager(delegate: notification)
                        uploadNotification.upload { _ in
                            
                        }
                        // upload to each member
                    }
                }
            }
            createGroupPost(with: workout.title!)
            
        } else if createdFor! != self.userID {
            // creating workout for one player
            
            createdWorkout["assigned"] = true as AnyObject
            let ref = workoutRef.child(createdFor!).childByAutoId()
            for step in 1...stepCount{
                if stepCount > 1 {
                    createdWorkout["title"] = workout.title! + " \(step)" as AnyObject
                }
                ref.setValue(createdWorkout)
            }
            let notification = NotificationNewWorkout(from: self.userID, to: createdFor!, workoutID: workout.workoutID!)
            let uploadNotification = NotificationManager(delegate: notification)
            uploadNotification.upload { _ in
                
            }
            uploadedWorkout?()
 
        } else {
            // this would be creating workout for self
            createdWorkout["assigned"] = false as AnyObject
            let ref = workoutRef.child(self.userID).childByAutoId()
            for step in 1...stepCount{
                if stepCount > 1{
                    createdWorkout["title"] = workout.title! + " \(step)" as AnyObject
                }
                ref.setValue(createdWorkout)
            }
            uploadedWorkout?()
        }
    }
    
    func uploadPost(with workout:workout, addToSaved: Bool, addToCreated: Bool, postToTimeline:Bool, isPrivate:Bool, stepCount:Int){
        var createdWorkout = workout.toObject()
        createdWorkout["NumberOfCompletes"] = 0 as AnyObject
        createdWorkout["NumberOfDownloads"] = 0 as AnyObject
        createdWorkout["TotalTime"] = 0 as AnyObject
        createdWorkout["TotalScore"] = 0 as AnyObject
        createdWorkout["isPrivate"] = isPrivate as AnyObject
        
        if !isPrivate {
            createdWorkout["Views"] = 0 as AnyObject
        }
        
        let savedReference = Database.database().reference().child("SavedWorkoutReferences").child(self.userID)
        let savedWorkoutRef = Database.database().reference().child("SavedWorkouts").childByAutoId()
        let savedWorkoutCreatorRefs = Database.database().reference().child("SavedWorkoutCreators").child(self.userID)
        let savedID = savedWorkoutRef.key!
        self.upload(with: workout, and: stepCount, savedID: savedID)
        
        savedWorkoutRef.setValue(createdWorkout)
        
        if addToSaved {
            savedReference.child(savedID).setValue(true)
        }
        
        if addToCreated {
            savedWorkoutCreatorRefs.child(savedID).setValue(true)
        }
        
        if postToTimeline {
            createdWorkout["savedID"] = savedID as AnyObject
            
            let postRef = Database.database().reference().child("Posts").childByAutoId()
            let postID = postRef.key!
            let postSelfReferences = Database.database().reference().child("PostSelfReferences")
            
            let timelineRef = Database.database().reference().child("Timeline")
            
            createdWorkout.removeValue(forKey: "NumberOfCompletes")
            createdWorkout.removeValue(forKey: "NumberOfDownloads")
            createdWorkout.removeValue(forKey: "TotalTime")
            createdWorkout.removeValue(forKey: "TotalScore")
            createdWorkout.removeValue(forKey: "Views")
            
            let postData = ["posterID":self.userID,
                            "workoutID":savedID,
                            "username":ViewController.username!,
                            "time":ServerValue.timestamp(),
                            "type":"createdNewWorkout",
                            "exerciseData":createdWorkout,
                            "isPrivate":isPrivate] as [String:AnyObject]
            
            
            postRef.setValue(postData)
            timelineRef.child(self.userID).child(postID).setValue(true)
            postSelfReferences.child(self.userID).child(postID).setValue(true)
            LoadFollowers.returnFollowers(for: self.userID) { (followers) in
                for follower in followers{
                    timelineRef.child(follower).child(postID).setValue(true)
                }
            }
        }
        
        if !isPrivate {
            // add to discover posts
            let discoverRef = Database.database().reference().child("Discover").child("Workouts")
            discoverRef.child(savedID).setValue(true)
        }
        

    }
    
    func updateWorkoutsCreated(){
        let actRef = Database.database().reference().child("users").child(self.userID)
        actRef.runTransactionBlock { (currentData) -> TransactionResult in
            if var userData = currentData.value as? [String:AnyObject]{
                var noOfWorkouts = userData["NumberOfWorkouts"] as? Int ?? 0
                noOfWorkouts += 1
                userData["NumberOfWorkouts"] = noOfWorkouts as AnyObject
                currentData.value = userData
                TransactionResult.success(withValue: currentData)
            }
            return TransactionResult.success(withValue: currentData)
        } andCompletionBlock: { (error, committed, snapshot) in
            if let error = error{
                print(error.localizedDescription)
            }
        }
    }
    
    
    func getData(at indexPath:IndexPath) -> [String:AnyObject]{
        return data[indexPath.row]
    }
    
    func changePrivacy(isPrivate:Bool){
        switch isPrivate {
        case true:
            self.data[2] = ["title":"Public",
                            "image":UIImage(named: "public_icon")!,
                "description":"This workout is public. This means that it can be viewed by everyone and it may appear on the discover page. Tap to change."] as [String:AnyObject]
        case false:
            self.data[2] = ["title":"Private",
                            "image":UIImage(named: "locked_icon")!,
                            "description":"This workout is private. This means it can only be viewed by your followers and players/coaches. Tap to Change."] as [String:AnyObject]
        }

    }
    
    func changeSaved(isSaved:Bool){
        switch isSaved {
        case true:
            self.data[3] = ["title":"Add to Saved",
                            "image":UIImage(named: "Workout UnCompleted")!,
                            "description":"Not adding this workout to your saved workouts. You won't be able to add this workout in the future. We do not recommend this. Tap to change."] as [String:AnyObject]
        case false:
            self.data[3] = ["title":"Add to Saved",
                            "image":UIImage(named: "Workout Completed")!,
                            "description":"Adding this workout to your saved workouts where you can add it to your workouts in the future. We recommend this. Tap to change."] as [String:AnyObject]

        }
    }
    
    func changeCreated(isCreated:Bool){
        switch isCreated {
        case true:
            self.data[4] = ["title":"Add to Created",
                            "image":UIImage(named: "Workout UnCompleted")!,
                            "description":"Not adding this workout to your created workout list. You won't be able to add this workout in the future. We do not recommend this. Tap to Change."] as [String:AnyObject]
        case false:
            self.data[4] = ["title":"Add to Created",
                            "image":UIImage(named: "Workout Completed")!,
                            "description":"Adding this workout to your created workout list where you can add it to your workouts in the future. We recommend this. Tap to Change."] as [String:AnyObject]
        }
    }
    
    func changePosting(isPosting:Bool){
        switch isPosting {
        case true:
            self.data[5] = ["title":"Post to Timeline",
                            "image":UIImage(named: "Workout UnCompleted")!,
                            "description":"Not posting this workout to the timeline. Tap to change."] as [String:AnyObject]
        case false:
            self.data[5] = ["title":"Post to Timeline",
                            "image":UIImage(named: "Workout Completed")!,
                            "description":"Posting this workout to the timeline. Your followers will be able to see this workout on the timeline. Tap to change."] as [String:AnyObject]

        }
    }
}
