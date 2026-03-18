//
//  File.swift
//  
//
//  Created by Findlay-Personal on 06/05/2023.
//

import Foundation

protocol WorkoutLoader {
    func loadAll() async throws -> [RemoteWorkoutModel]
    func writeNew(_ model: RemoteWorkoutModel) async throws
}

class RemoteWorkoutLoader: WorkoutLoader {
    var networkService: NetworkService
    var userService: CurrentUserServiceWorkoutKit
    
    init(networkService: NetworkService, userService: CurrentUserServiceWorkoutKit) {
        self.networkService = networkService
        self.userService = userService
    }
    
    func loadAll() async throws -> [RemoteWorkoutModel] {
        let workouts: [RemoteWorkoutModel] = try await networkService.readAll(at: Constants.workoutsPath(userService.currentUserUID))
        return workouts
    }
    func writeNew(_ model: RemoteWorkoutModel) async throws {
        try await networkService.write(data: model, at: Constants.workoutPath(userService.currentUserUID, workoutID: model.id))
    }
}
