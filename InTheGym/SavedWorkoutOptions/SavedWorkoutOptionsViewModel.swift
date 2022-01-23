//
//  SavedWorkoutOptionsViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 19/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import Combine

class SavedWorkoutOptionsViewModel {
    
    // MARK: - Publisher
    var creatorUser = CurrentValueSubject<Users?,Never>(nil)
    var workoutSaved = CurrentValueSubject<Bool,Never>(false)
    var errorFetchingUser = PassthroughSubject<Error,Never>()
    
    // MARK: - Properties
    var savedWorkout: SavedWorkoutModel!
    
    var apiService: FirebaseDatabaseManagerService
    
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
    }
    
    // MARK: - Fetch
    func fetchCreator() {
        if savedWorkout.creatorID == FirebaseAuthManager.currentlyLoggedInUser.uid {
            creatorUser.send(FirebaseAuthManager.currentlyLoggedInUser)
            creatorUser.send(completion: .finished)
        } else {
            let searchModel = UserSearchModel(uid: savedWorkout.creatorID)
            apiService.fetchSingleInstance(of: searchModel, returning: Users.self) { [weak self] result in
                guard let self = self else {return}
                switch result {
                case .success(let user):
                    self.creatorUser.send(user)
                    self.creatorUser.send(completion: .finished)
                case .failure(let error):
                    self.errorFetchingUser.send(error)
                }
            }
        }
    }
    
    // MARK: - Check Save
    func checkSaved() {
        let refModel = SavedWorkoutReferenceModel(id: savedWorkout.savedID)
        apiService.checkExistence(of: refModel) { [weak self] result in
            guard let self = self else {return}
            switch result {
            case .success(let saved):
                self.workoutSaved.send(saved)
            case .failure(let error):
                self.errorFetchingUser.send(error)
            }
        }
    }
    
    // MARK: - Upload Functions
    func addToSaved() {
        let refModel = SavedWorkoutReferenceModel(id: savedWorkout.savedID).toMultipUploadPoint()
        let downloadsModel = savedWorkout.downloadUploadPoint()
        let uploadPoints: [FirebaseMultiUploadDataPoint] = [refModel, downloadsModel]
        apiService.multiLocationUpload(data: uploadPoints) { [weak self] result in
            guard let self = self else {return}
            switch result {
            case .success(()):
                print("successfully uploaded to saved and added a download")
            case .failure(let error):
                self.errorFetchingUser.send(error)
            }
        }
        
//        apiService.upload(data: savedWorkout, autoID: false) { [weak self] result in
//            guard let self = self else {return}
//            switch result {
//            case .success(()):
//                print("successfully uploaded to saved")
//            case .failure(let error):
//                self.errorFetchingUser.send(error)
//            }
//        }
    }
    func addToWorkouts() {
        let workoutModel = WorkoutModel(savedModel: savedWorkout, assignTo: FirebaseAuthManager.currentlyLoggedInUser.uid)
        apiService.upload(data: workoutModel, autoID: false) { [weak self] result in
            guard let self = self else {return}
            switch result {
            case .success(()):
                print("successfully uploaded tp workouts")
            case .failure(let error):
                self.errorFetchingUser.send(error)
            }
        }
    }
    
    // MARK: - Retreiving Function
    func getCreator() -> Users? {
        let creator = creatorUser.value
        return creator
    }
}
