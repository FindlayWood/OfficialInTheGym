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
    var addedSummaryPublisher = PassthroughSubject<String,Never>()
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
        apiService.multiLocationUpload(data: uploadPoints) { [weak self] result in
            switch result {
            case .success(()):
                self?.uploadWorkload()
                self?.uploadScore()
                self?.uploadMyWorkoutStats()
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
            case .success(_):
                break
            case .failure(_):
                self?.uploadScore()
            }
        }
    }
    func uploadMyWorkoutStats() {
        guard let time = workout.timeToComplete else {return}
        let uploadModel = MyWorkoutStatsUploadModel(time: time)
        apiService.multiLocationUpload(data: uploadModel.uploadPoints) { [weak self] result in
            switch result {
            case .success(_):
                break
            case .failure(_):
                self?.uploadMyWorkoutStats()
            }
        }
    }
    
    func checkCompleted() {
        if !(workout.completed) {
            workout.timeToComplete = nil
            workout.score = nil
            workout.summary = nil
        }
    }
}
