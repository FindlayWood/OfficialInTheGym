//
//  File.swift
//  
//
//  Created by Findlay-Personal on 08/05/2023.
//

import Foundation

protocol ExerciseLoader {
    func loadAll(for workout: RemoteWorkoutModel) async throws -> [RemoteExerciseModel]
}

class RemoteExerciseLoader: ExerciseLoader {
    var networkService: NetworkService
    
    init(networkService: NetworkService) {
        self.networkService = networkService
    }
    
    func loadAll(for workout: RemoteWorkoutModel) async throws -> [RemoteExerciseModel] {
        let exercises: [RemoteExerciseModel] = try await networkService.readAll(at: Constants.exercisePath(workout.id, workout.assignedTo))
        return exercises
    }
}
