//
//  DisplaySavedWorkoutsViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 05/03/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit
import Firebase


class DisplayWorkoutViewModel: NSObject{
    
    // MARK: - Closures
        
    // Through these closures, our view model will execute code while some events will occure
    // They will be set up by the view controller
    
    var reloadTableViewClosure: (() -> ())?
    var updateLoadingStatusClosure: (() -> ())?
    var bottomViewSetUpClosure: (() -> ())?
    var workoutReadyToStartClosure: (() ->())?
    
    let userId = Auth.auth().currentUser?.uid
    let notificationFeedbackGenerator = UINotificationFeedbackGenerator()

    
    init(workout : WorkoutDelegate) {
        self.selectedWorkout = workout
    }
    
    // MARK: - Properties
    
    var selectedWorkout: WorkoutDelegate?
    
    
    // the bottom view to be displayed
    var bottomView: UIView = UIView() {
        didSet {
            self.bottomViewSetUpClosure?()
        }
    }
    
    // A property containing the number ot items, it will be used by the view controller to render items on the screen using a
    var numberOfItems: Int {
        guard let exercises = selectedWorkout?.exercises else {return 0}
        return exercises.count
    }
    
    // MARK: -Setup
    func setup(){
        // in here set the correct variation of the page
        // could be bottom view, discover bottom view, saved bottom view, no view or button
        
    }
    
    var delegate: DisplayWorkoutProtocol!


    // MARK: - Retieve Data

    func getData(at indexPath: IndexPath ) -> WorkoutType {
        //let selectedWorkoutExercises = selectedWorkout?.exercises as! [exercise]
        //return selectedWorkoutExercises[indexPath.section]
        return (selectedWorkout?.exercises![indexPath.section])!
    }
    
    func getClipData(at indexPath: IndexPath) -> clipDataModel {
        return (selectedWorkout?.clipData?[indexPath.item])!
    }
    
    func isLive() -> Bool {
        if let completableWorkout = selectedWorkout as? Completeable {
            if completableWorkout.liveWorkout ?? false && !(completableWorkout.completed) {
                return true
            } else {
                return false
            }
        } else {
            return false
        }
//        if selectedWorkout?.liveWorkout ?? false && !(selectedWorkout?.completed ?? false) {
//            return true
//        } else {
//            return false
//        }
    }
    func isCreatingNew() -> Bool {
        if selectedWorkout is CreatingNewWorkout {
            return true
        } else {
            return false
        }
    }
    
    func updateCompletedSet(at indexPath: IndexPath){
        // must update database
        let ref = Database.database().reference().child("Workouts").child(self.userId!).child((selectedWorkout?.workoutID!)!).child("exercises").child("\(indexPath.section)").child("completedSets")
        let selectedWorkoutExercises = selectedWorkout?.exercises![indexPath.section] as! exercise
        selectedWorkoutExercises.completedSets![indexPath.item] = true
        //self.selectedWorkout?.exercises![indexPath.section].completedSets![indexPath.item] = true
        ref.child("\(indexPath.item)").setValue(true)
        
        let type = getData(at: indexPath)
        guard let exercise = type as? exercise else {return}
        let weight = exercise.weightArray?[indexPath.item]
        guard let name = exercise.exercise,
              let reps = exercise.repArray?[indexPath.item]
        else {
            return
        }
        FirebaseAPIWorkoutManager.shared.checkForExerciseStats(name: name, reps: reps, weight: weight)
    }
    
    func updateRPE(at indexPath: IndexPath, with rpe:Int){
        // update database
        // update model selected workout
        let selectedWorkoutExercises = selectedWorkout?.exercises![indexPath.section] as! exercise
        selectedWorkoutExercises.rpe = rpe.description
        //self.selectedWorkout?.exercises![indexPath.section].rpe = rpe.description
        let ref = Database.database().reference().child("Workouts").child(self.userId!).child((selectedWorkout?.workoutID!)!).child("exercises").child("\(indexPath.section)")
        ref.child("rpe").setValue(rpe.description)
        
        let type = getData(at: indexPath)
        guard let exercise = type as? exercise else {return}
        guard let name = exercise.exercise else {return}
        FirebaseAPIWorkoutManager.shared.checkForCompletionStats(name: name, rpe: rpe)
    }
    
    // MARK: - Setup functions
    
    func startTheWorkout(){
        // start the workout, add starttime, update database with starttime,
        let s = selectedWorkout as! workout
        s.startTime = Date.timeIntervalSinceReferenceDate
        let ref = Database.database().reference().child("Workouts").child(self.userId!).child(selectedWorkout!.workoutID!)
        ref.child("startTime").setValue(Date.timeIntervalSinceReferenceDate) { (error, snapshot) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                // tell delegate that we are ready to start workout
                self.workoutReadyToStartClosure?()
            }
        }
        
    }
    
    func addToSavedWorkouts(){
        // add to saved workouts, show top view
        // check that workout hasnt already been saved
        
        let savedWorkoutRef = Database.database().reference().child("SavedWorkoutReferences").child(self.userId!).child(selectedWorkout!.savedID)
        savedWorkoutRef.observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists(){
                // show already saved to user
                self.delegate.returnAlreadySaved(saved: true)
            }else{
                savedWorkoutRef.setValue(true)
                self.delegate.returnAlreadySaved(saved: false)
                self.addADownload()
                self.notificationFeedbackGenerator.prepare()
                self.notificationFeedbackGenerator.notificationOccurred(.success)
            }
        }
        
        
    }
    
    func addToWorkouts(){
        // add to workouts, show top view
        let workoutRef = Database.database().reference().child("Workouts").child(userId!).childByAutoId()
        var theWorkout = selectedWorkout?.toObject()
        theWorkout?.removeValue(forKey: "Views")
        theWorkout?.removeValue(forKey: "NumberOfCompletes")
        theWorkout?.removeValue(forKey: "NumberOfDownloads")
        theWorkout?.removeValue(forKey: "TotalScore")
        theWorkout?.removeValue(forKey: "TotalTime")
        workoutRef.setValue(theWorkout)
        notificationFeedbackGenerator.prepare()
        notificationFeedbackGenerator.notificationOccurred(.success)
    }
    
    func addAView(to workout:WorkoutDelegate){
        let ref = Database.database().reference().child("SavedWorkouts").child(workout.savedID)
        ref.runTransactionBlock { (currentData) -> TransactionResult in
            if var workout = currentData.value as? [String:AnyObject]{
                var views = workout["Views"] as? Int ?? 0
                views += 1
                workout["Views"] = views as AnyObject
                currentData.value = workout
                return TransactionResult.success(withValue: currentData)
            }
            return TransactionResult.success(withValue: currentData)
        } andCompletionBlock: { (error, committed, snapshot) in
            if let error = error{
                print(error.localizedDescription)
            }
        }
        
    }
    
    func addADownload(){
        let ref = Database.database().reference().child("SavedWorkouts").child(selectedWorkout!.savedID)
        ref.runTransactionBlock { (currentData) -> TransactionResult in
            if var workout = currentData.value as? [String:AnyObject]{
                var downloads = workout["NumberOfDownloads"] as? Int ?? 0
                downloads += 1
                workout["NumberOfDownloads"] = downloads as AnyObject
                currentData.value = workout
                return TransactionResult.success(withValue: currentData)
            }
            return TransactionResult.success(withValue: currentData)
        } andCompletionBlock: { (error, committed, snapshot) in
            if let error = error{
                print(error.localizedDescription)
            }
        }
    }
    
}
