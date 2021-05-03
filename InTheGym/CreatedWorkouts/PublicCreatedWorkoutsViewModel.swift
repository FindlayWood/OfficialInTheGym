//
//  PublicCreatedWorkoutsViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 26/04/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import Firebase
import UIKit

class PublicCreatedWorkoutsViewModel:NSObject {
    
    // MARK: - Closures
        
    // Through these closures, our view model will execute code while some events will occure
    // They will be set up by the view controller
    
    var reloadTableViewClosure: (() -> ())?
    var updateLoadingStatusClosure: (() -> ())?
    
    // MARK: - Properties
    
    // We defined the FakeAPIServiceProtocol in the FakeAPIService.swift file.
    // We also defined a class and make it conform to that protocol.
    var apiService: DatabaseReference
    var handle : DatabaseHandle!
    let user : Users!
    let userID = Auth.auth().currentUser?.uid
    
    

    // This will contain info about the picture eventually selectded by the user by tapping an item on the screen
    var selectedWorkout: CreatedWorkoutDelegate?
    
    // The collection that will contain our fetched data
    private var createdWorkouts: [CreatedWorkoutDelegate] = [] {
        didSet {
            self.reloadTableViewClosure?()
        }
    }
    
    // A property containing the number ot items, it will be used by the view controller to render items on the screen using a
    var numberOfItems: Int {
        return createdWorkouts.count
    }
    
    var isLoading: Bool = false {
        didSet {
            self.updateLoadingStatusClosure?()
        }
    }
    
    var isFollowing: Bool! {
        didSet{
            loadReferences()
        }
    }
    
    // MARK: - Constructor
    
    // Note: apiService has a default value in case this constructor is executed without passing parameters
    init(for user:Users) {
        self.user = user
        self.apiService = Database.database().reference().child("SavedWorkoutCreators").child(user.uid!)
    }
    
    // MARK: - Check if following
    
    func checkFollowing(){
        self.isLoading = true
        let ref = Database.database().reference().child("Following").child(self.userID!).child(user.uid!)
        ref.observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists() {
                self.isFollowing = true
            } else {
                self.isFollowing = false
            }
        }
    }
    
    
    
    // MARK: - Fetching functions
    
    func fetchData() {
        self.isLoading = true
        self.loadReferences()
        
    }
    
    // MARK: - Saved Workout Downloading
    func loadReferences(){
        var workoutReferences : [String] = []
        handle = apiService.observe(.childAdded) { (snapshot) in
            workoutReferences.append(snapshot.key)
        }
        
        apiService.observeSingleEvent(of: .value) { (_) in
            self.loadSavedWorkouts(with: workoutReferences)
        }
        
    }
    
    func loadSavedWorkouts(with references: [String]){
        
        var tempWorkouts = [CreatedWorkoutDelegate]()
        let myGroup = DispatchGroup()
        let api = Database.database().reference().child("SavedWorkouts")
        
        if references.isEmpty {
            self.isLoading = false
            self.createdWorkouts = []
        }
        
        for workout in references{
            myGroup.enter()
            api.child(workout).observeSingleEvent(of: .value) { (snapshot) in
                defer {myGroup.leave()}
                
                guard let snap = snapshot.value as? [String:AnyObject] else{
                    return
                }
                
                if self.isFollowing || snap["isPrivate"] as? Bool ?? true == false {
                    switch snap["isPrivate"] as! Bool {
                    case true:
                        tempWorkouts.append(PrivateCreatedWorkout(snapshot: snapshot)!)
                    case false:
                        tempWorkouts.append(PublicCreatedWorkout(snapshot: snapshot)!)
                    }
                }
                
            }
            myGroup.notify(queue: .main){
                self.createdWorkouts = tempWorkouts
                self.isLoading = false
            }
        }
    }
    
    //MARK: - RemoveObservers
    func removeObservers(){
        apiService.removeObserver(withHandle: handle)
    }
    
    
    // MARK: - Retieve Data
    
    func getData( at indexPath: IndexPath ) -> CreatedWorkoutDelegate {
        return createdWorkouts[indexPath.section]
    }
}
