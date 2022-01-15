//
//  SavedWorkoutsViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 03/03/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import Combine

class SavedWorkoutsViewModel:NSObject {
    
    // MARK: - Publishers
    var savedWorkoutss = CurrentValueSubject<[SavedWorkoutModel],Never>([])
    var errorFetchingWorkouts = PassthroughSubject<Error,Never>()
    
    // MARK: - Closures
        
    // Through these closures, our view model will execute code while some events will occure
    // They will be set up by the view controller
    
//    var reloadTableViewClosure: (() -> ())?
//    var updateLoadingStatusClosure: (() -> ())?
    
    // MARK: - Properties
    
    // We defined the FakeAPIServiceProtocol in the FakeAPIService.swift file.
    // We also defined a class and make it conform to that protocol.
//    var apiService: DatabaseReference
//    var handle : DatabaseHandle!
//    let userID = Auth.auth().currentUser!.uid
    
    var apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared
    // This will contain info about the picture eventually selectded by the user by tapping an item on the screen
//    var selectedWorkout: savedWorkoutDelegate?
    
    // The collection that will contain our fetched data
//    private var savedWorkouts: [savedWorkoutDelegate] = [] {
//        didSet {
//            self.reloadTableViewClosure?()
//        }
//    }
    
    // A property containing the number ot items, it will be used by the view controller to render items on the screen using a
//    var numberOfItems: Int {
//        return savedWorkouts.count
//    }
    
//    var isLoading: Bool = false {
//        didSet {
//            self.updateLoadingStatusClosure?()
//        }
//    }
    
    
    // MARK: - Constructor
    
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
    }
    // Note: apiService has a default value in case this constructor is executed without passing parameters
//    override init() {
//        self.apiService = Database.database().reference().child("SavedWorkoutReferences").child(userID)
//    }
    
    
    // MARK: - Fetching functions
    
//    func fetchData() {
//        self.isLoading = true
//        self.loadReferences()
//    }
    
    func fetchKeys() {
        
        apiService.fetchKeys(from: SavedWorkoutKeyModel.self) { [weak self] result in
            guard let self = self else {return}
            switch result {
            case .success(let keys):
                self.loadWorkouts(from: keys)
            case .failure(let error):
                self.errorFetchingWorkouts.send(error)
            }
        }
    }
    
    func loadWorkouts(from keys: [String]) {
        let savedKeysModel = keys.map { SavedWorkoutKeyModel(id: $0) }
        apiService.fetchRange(from: savedKeysModel, returning: SavedWorkoutModel.self) { [weak self] result in
            guard let self = self else {return}
            switch result {
            case .success(let savedWorkoutModels):
                self.savedWorkoutss.send(savedWorkoutModels)
            case .failure(let error):
                self.errorFetchingWorkouts.send(error)
            }
        }
    }
    
    // MARK: - Saved Workout Downloading
//    func loadReferences(){
//        var workoutReferences : [String] = []
//        handle = apiService.observe(.childAdded) { (snapshot) in
//            workoutReferences.append(snapshot.key)
//        }
//
//        apiService.observeSingleEvent(of: .value) { (_) in
//            self.loadSavedWorkouts(with: workoutReferences)
//        }
//
//    }
    
//    func loadSavedWorkouts(with references: [String]){
//
//        var tempWorkouts = [savedWorkoutDelegate]()
//        let myGroup = DispatchGroup()
//        let api = Database.database().reference().child("SavedWorkouts")
//
//        if references.isEmpty {
//            self.savedWorkouts = []
//            self.isLoading = false
//        }
//
//        for workout in references{
//             myGroup.enter()
//             api.child(workout).observeSingleEvent(of: .value) { (snapshot) in
//                 defer {myGroup.leave()}
//
//                 guard let snap = snapshot.value as? [String:AnyObject] else{
//                     return
//                 }
//
//                 switch snap["isPrivate"] as! Bool {
//                 case true:
//                     tempWorkouts.append(privateSavedWorkout(snapshot: snapshot)!)
//                 case false:
//                     tempWorkouts.append(publicSavedWorkout(snapshot: snapshot)!)
//                 }
//             }
//             myGroup.notify(queue: .main){
//                 self.savedWorkouts = tempWorkouts
//                 self.isLoading = false
//             }
//         }
//    }
    
    //MARK: - RemoveObservers
//    func removeObservers(){
//        apiService.removeObserver(withHandle: handle)
//    }
    
    // MARK: - Retieve Data
    
//    func getData( at indexPath: IndexPath ) -> savedWorkoutDelegate {
//        return savedWorkouts[indexPath.section]
//    }
    
    func workoutSelected(at indexPath: IndexPath) -> SavedWorkoutModel {
        let currentWorkouts = savedWorkoutss.value
        return currentWorkouts[indexPath.row]
    }
}
