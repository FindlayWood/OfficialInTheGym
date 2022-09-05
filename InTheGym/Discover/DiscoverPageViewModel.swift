//
//  DiscoverPageViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 15/04/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import Combine

class DiscoverPageViewModel {
    
    // MARK: - Publishers
    var workoutModelsPublisher = CurrentValueSubject<[SavedWorkoutModel],Never>([])
    
    var exercisesPublisher = CurrentValueSubject<[DiscoverExerciseModel],Never>([])
    
    var tagsPublisher = CurrentValueSubject<[ExerciseTagReturnModel],Never>([])
    
    var clipsPublisher = CurrentValueSubject<[ClipModel],Never>([])
    
    var programPublisher = CurrentValueSubject<[SavedProgramModel],Never>([])
    
    var errorPublisher = PassthroughSubject<Error,Never>()
    
    var workoutSelected = PassthroughSubject<SavedWorkoutModel,Never>()
    
    var exerciseSelected = PassthroughSubject<DiscoverExerciseModel,Never>()
    
    var programSelected = PassthroughSubject<SavedProgramModel,Never>()
    
    var clipSelected = PassthroughSubject<ClipModel,Never>()
    
    var tagSelected = PassthroughSubject<String,Never>()
    
    // MARK: - Properties
    var apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared
    
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
    }
    
    // MARK: - Functions
    func loadWorkouts() {
        apiService.fetchLimited(model: SavedWorkoutModel.self, limit: 10) { [weak self] result in
            switch result {
            case .success(let models):
                let filteredModels = models.filter { !($0.isPrivate) }
                self?.workoutModelsPublisher.send(filteredModels)
            case .failure(let error):
                self?.errorPublisher.send(error)
            }
        }
    }
    func loadExercises() {
        let exercises: [DiscoverExerciseModel] = [.init(exerciseName: "Bench Press"), .init(exerciseName: "Squats"),
                                                  .init(exerciseName: "Pull Ups"), .init(exerciseName: "Press Ups"),
                                                  .init(exerciseName: "Jumping Jacks"), .init(exerciseName: "Bicep Curls"),
                                                  .init(exerciseName: "Deadlifts"), .init(exerciseName: "Eccentric Nordic Hamstring Curls")]
        exercisesPublisher.send(exercises)
    }
    func loadClips() {
        apiService.fetchLimited(model: ClipModel.self, limit: 10) { [weak self] result in
            switch result {
            case .success(let models):
                let filteredModels = models.filter { !($0.isPrivate) }.sorted { $0.time > $1.time }
                self?.clipsPublisher.send(filteredModels)
            case .failure(let error):
                self?.errorPublisher.send(error)
                print(String(describing: error))
            }
        }
    }
    func loadPrograms() {
//        apiService.fetchLimited(model: SavedProgramModel.self, limit: 10) { [weak self] result in
//            switch result {
//            case .success(let models):
//                self?.programPublisher.send(models)
//            case .failure(let error):
//                self?.errorPublisher.send(error)
//            }
//        }
    }
    
    func loadTags() {
        let tagModels: [ExerciseTagReturnModel] = [.init(tag: "chest"),.init(tag: "triceps"),.init(tag: "legs"),.init(tag: "power"),.init(tag: "hamstring"),.init(tag: "warmup"),]
        tagsPublisher.send(tagModels)
    }
    
    // MARK: - Actions
    func itemSelected(_ item: DiscoverPageItems) {
        switch item {
        case .workout(let savedWorkoutModel):
            workoutSelected.send(savedWorkoutModel)
        case .exercise(let discoverExerciseModel):
            exerciseSelected.send(discoverExerciseModel)
        case .tag(let exerciseTagModel):
            tagSelected.send(exerciseTagModel.tag)
        case .clip(let clipModel):
            clipSelected.send(clipModel)
        }
    }
}


