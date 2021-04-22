//
//  DiscoverPageViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 15/04/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import Firebase
import SCLAlertView

class DiscoverPageViewModel {
    
    // closures
    var updatewodLoadinsStatusClosure:(()->())?
    var updateWorkoutsLoadingStatusClosure:(()->())?
    var tableViewReloadClosure:(()->())?
    var wodLoadedClosure:(()->())?
    
    private var workouts : [discoverWorkout] =  [] {
        didSet{
            self.tableViewReloadClosure?()
        }
    }
    
    private var workoutOfTheDay : discoverWorkout! {
        didSet{
            self.wodLoadedClosure?()
            self.wodLoaded = true
        }
    }
    
    var numberOfWorkouts : Int {
        return workouts.count
    }
    
    var wodLoaded : Bool = false
    
    var isWODLoading : Bool = false {
        didSet{
            self.updatewodLoadinsStatusClosure?()
        }
    }
    
    var isWorkoutsLoading : Bool = false {
        didSet{
            self.updateWorkoutsLoadingStatusClosure?()
        }
    }
    
    
    /// fetches the workout of the day key
    func fetchWODKey(){
        self.isWODLoading = true
        let ref = Database.database().reference().child("Discover").child("WOD")
        ref.observeSingleEvent(of: .value) { (snapshot) in
            for child in snapshot.children {
                let wodkey:String = (child as AnyObject).key
                self.loadWOD(with: wodkey)
            }
        }
    }
    
    
    /// loads the workout of the day from the given key
    /// - Parameter key: id of where the WOD is stored within discover workouts
    func loadWOD(with key:String){
        let ref = Database.database().reference().child("SavedWorkouts").child(key)
        ref.observeSingleEvent(of: .value) { (snapshot) in
            let wod = discoverWorkout(snapshot: snapshot)!
            self.workoutOfTheDay = wod
            self.isWODLoading = false
        }
    }
    
    
    /// fetches the workouts to be displayed
    func fetchWorkoutKeys(){
        self.isWorkoutsLoading = true
        var workoutKeys = [String]()
        let ref = Database.database().reference().child("Discover").child("Workouts")
        ref.observeSingleEvent(of: .value) { (snapshot) in
            for child in snapshot.children{
                workoutKeys.append((child as AnyObject).key)
            }
            self.loadWorkouts(with: workoutKeys)
            
        }
//        ref.observeSingleEvent(of: .value) { (_) in
//            self.loadWorkouts(with: workoutKeys)
//        }
    }
    
    
    /// loads the workouts as discover workouts from keys
    /// - Parameter keys: array of ids where the workouts are stored
    func loadWorkouts(with keys:[String]){
        var tempWorkouts = [discoverWorkout]()
        let myGroup = DispatchGroup()
        let ref = Database.database().reference().child("SavedWorkouts")
        for key in keys{
            myGroup.enter()
            ref.child(key).observeSingleEvent(of: .value) { (snapshot) in
                defer {myGroup.leave()}
                let workout = discoverWorkout(snapshot: snapshot)!
                tempWorkouts.insert(workout, at: 0)
            }
        }
        myGroup.notify(queue: .main){
            tempWorkouts.sort(by: { $0.numberOfDownloads! > $1.numberOfDownloads! })
            self.workouts = tempWorkouts
            self.isWorkoutsLoading = false
        }
    }
    
    
    func getWorkout(at indexPath:IndexPath) -> discoverWorkout{
        return workouts[indexPath.item]
    }
    
    func getWOD() -> discoverWorkout {
        return workoutOfTheDay
    }
    
    
}


