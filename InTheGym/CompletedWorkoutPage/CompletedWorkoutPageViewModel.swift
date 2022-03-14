//
//  CompletedWorkoutPageViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 01/02/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import Combine

class CompletedWorkoutPageViewModel {
    
    // MARK: - Publisher
    var completedUpload = PassthroughSubject<Void,Never>()
    var errorUpload = PassthroughSubject<Error,Never>()
    
    @Published var isLoading: Bool = false
    
    // MARK: - Properties
    var workout: WorkoutModel!
    
    var apiService: FirebaseDatabaseManagerService
    
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
    }
    
    func addRPEScore(_ score: Int) {
        workout.score = score
        workout.workload = workout.getWorkload()
    }
    
    func upload() {
        isLoading = true
        workout.completed = true
        let uploadModel = CompletedWorkoutUploadModel(workout: workout)
        let uploadPoints = uploadModel.uploadPoints()
        print(uploadPoints)
        apiService.multiLocationUpload(data: uploadPoints) { [weak self] result in
            switch result {
            case .success(()):
//                self?.completedUpload.send(())
//                self?.isLoading = false
                self?.uploadWorkload()
                self?.uploadScore()
            case .failure(let error):
                self?.errorUpload.send(error)
                self?.isLoading = false
            }
        }
    }
    
    func uploadWorkload() {
        guard let score = workout.score,
              let time = workout.timeToComplete,
              let workload = workout.workload
        else {return}
        
        let workloadModel = WorkloadModel(id: UUID().uuidString,
                                          endTime: Date().timeIntervalSince1970,
                                          rpe: score,
                                          timeToComplete: time,
                                          workload: workload,
                                          workoutID: workout.id)
        apiService.uploadTimeOrderedModel(model: workloadModel) { [weak self] result in
            switch result {
            case .success(_):
                self?.completedUpload.send(())
                self?.isLoading = false
            case .failure(_):
                self?.uploadWorkload()
            }
        }
    }
    func uploadScore() {
        guard let score = workout.score else {return}
        let scoreModel = ScoresModel(id: UUID().uuidString, score: score)
        apiService.uploadTimeOrderedModel(model: scoreModel) { [weak self] result in
            switch result {
            case .success(let model):
                break
            case .failure(_):
                self?.uploadScore()
            }
        }
    }
    
    func checkCompleted() {
        if !(workout.completed) {
            workout.timeToComplete = nil
        }
    }
}
