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
    
    let userId = Auth.auth().currentUser?.uid
    let notificationFeedbackGenerator = UINotificationFeedbackGenerator()

    
    init(workout : WorkoutDelegate) {
        self.selectedWorkout = workout
    }
    
    // MARK: - Properties
    
    var selectedWorkout : WorkoutDelegate?
    
    
    // the bottom view to be displayed
    var bottomView: UIView = UIView() {
        didSet {
            self.bottomViewSetUpClosure?()
        }
    }
    
    // A property containing the number ot items, it will be used by the view controller to render items on the screen using a
    var numberOfItems: Int {
        return (selectedWorkout?.exercises!.count)!
    }
    
    // MARK: -Setup
    func setup(){
        // in here set the correct variation of the page
        // could be bottom view, discover bottom view, saved bottom view, no view or button
        
    }
    
    var delegate: DisplayWorkoutProtocol!


    // MARK: - Retieve Data

    func getData(at indexPath: IndexPath ) -> exercise {
        
        return (selectedWorkout?.exercises![indexPath.section])!
    }
    
    func isLive() -> Bool {
        
        return selectedWorkout!.liveWorkout
    }
    
    func updateCompletedSet(at indexPath: IndexPath){
        // must update database
        self.selectedWorkout?.exercises![indexPath.section].completedSets![indexPath.item] = true
        
    }
    
    func updateRPE(at indexPath: IndexPath, with rpe:Int){
        // update database
        // update model selected workout
        self.selectedWorkout?.exercises![indexPath.section].rpe = rpe
    }
    
    // MARK: - Setup functions
    
    func startTheWorkout(){
        // start the workout, add starttime, update database with starttime,
        
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
            }
        }
        
        
    }
    
    func addToWorkouts(){
        // add to workouts, show top view
        let workoutRef = Database.database().reference().child("Workouts").child(userId!).childByAutoId()
        workoutRef.setValue(selectedWorkout?.toObject())
        notificationFeedbackGenerator.prepare()
        notificationFeedbackGenerator.notificationOccurred(.success)
    
        
    }
    
}
