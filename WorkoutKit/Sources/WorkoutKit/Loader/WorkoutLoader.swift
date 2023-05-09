//
//  File.swift
//  
//
//  Created by Findlay-Personal on 06/05/2023.
//

import Foundation

protocol WorkoutLoader {
    func loadAll() async throws -> [RemoteWorkoutModel]
}

class RemoteWorkoutLoader: WorkoutLoader {
    var networkService: NetworkService
    var userService: CurrentUserServiceWorkoutKit
    
    init(networkService: NetworkService, userService: CurrentUserServiceWorkoutKit) {
        self.networkService = networkService
        self.userService = userService
    }
    
    func loadAll() async throws -> [RemoteWorkoutModel] {
        let workouts: [RemoteWorkoutModel] = try await networkService.readAll(at: Constants.workoutPath(userService.currentUserUID))
        return workouts
    }
}
