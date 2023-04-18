//
//  SavedWorkoutsDisplayViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 19/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import Combine

class SavedWorkoutDisplayViewModel {
    
    // MARK: - Publisher
    var listListener: SavedWorkoutRemoveListener?
    
    // MARK: - Properties
    var savedWorkout: SavedWorkoutModel!
    
    lazy var exercises: [ExerciseType] = {
        var exercises = [ExerciseType]()
        exercises.append(contentsOf: savedWorkout.exercises ?? [])
        exercises.append(contentsOf: savedWorkout.circuits ?? [])
        exercises.append(contentsOf: savedWorkout.amraps ?? [])
        return exercises.sorted(by: { $0.workoutPosition < $1.workoutPosition} )
    }()
    
    var apiService: FirebaseDatabaseManagerService
    
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
    }
    
    func updateRPE(at index: IndexPath, to score: Int) {
        guard let exercise = exercises[index.item] as? ExerciseModel else {return}
//        exercise.rpe = score
        let rpeUpdateModel = RPEUpdateModel(workoutID: savedWorkout.id, exercise: exercise)
        let uploadPoint = FirebaseMultiUploadDataPoint(value: score, path: rpeUpdateModel.internalPath)
        apiService.multiLocationUpload(data: [uploadPoint]) { [weak self] result in
            switch result {
            case .success(()):
                print("success")
            case .failure(let error):
                print("error")
            }
        }
    }
    
    func addAView() {
        if savedWorkout.creatorID != UserDefaults.currentUser.uid {
            let uploadPoints: [FirebaseMultiUploadDataPoint] = [savedWorkout.viewUploadPoint()]
            apiService.multiLocationUpload(data: uploadPoints) { [weak self] result in
                guard let self = self else {return}
                switch result {
                case .success(()):
                    print("successfully uploaded to saved and added a download")
                case .failure(let error):
                    print(String(describing: error))
                }
            }
        }
    }
    
    // MARK: - Functions
    
}
