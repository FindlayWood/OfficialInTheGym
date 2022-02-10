//
//  CompletedWorkoutPageViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 01/02/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation

class CompletedWorkoutPageViewModel {
    
    // MARK: - Properties
    var workout: WorkoutModel!
    
    var apiService: FirebaseDatabaseManagerService
    
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
    }
    
    
    func upload() {
        let uploadModel = CompletedWorkoutUploadModel(workout: workout)
        let uploadPoints = uploadModel.uploadPoints()
        print(uploadPoints)
        apiService.multiLocationUpload(data: uploadPoints) { [weak self] result in
            switch result {
            case .success(()):
                break
            case .failure(_):
                // TODO: - Error
                break
            }
        }
        guard let score = workout.score,
              let time = workout.timeToComplete,
              let workload = workout.workload
        else {return}
        
        let workloadModel = WorkloadModel(id: UUID().uuidString,
                                          endTime: Date().timeIntervalSince1970,
                                          rpe: score,
                                          timeToComplete: time,
                                          workload: workload,
                                          workoutID: workout.workoutID)
        apiService.upload(data: workloadModel, autoID: false) { [weak self] result in
            switch result {
            case .success(()):
                break
            case .failure(_):
                // TODO: - Error
                break
            }
        }
    }
}
