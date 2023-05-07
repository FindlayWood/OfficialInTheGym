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

protocol WorkoutManager {
    var workouts: [RemoteWorkoutModel] { get }
    var workoutsPublished: Published<[RemoteWorkoutModel]> { get }
    var workoutsPublisher: Published<[RemoteWorkoutModel]>.Publisher { get }
    func loadWorkouts() async throws
    func addNew(_ workout: RemoteWorkoutModel)
    func delete(_ workout: RemoteWorkoutModel)
    func loadExercises(for workout: RemoteWorkoutModel) async throws -> [RemoteExerciseModel]
}

class RemoteWorkoutManager: WorkoutManager {
    
    var workoutLoader: WorkoutLoader
    var exerciseLoader: ExerciseLoader
    
    @Published var workouts: [RemoteWorkoutModel] = []
    var workoutsPublished: Published<[RemoteWorkoutModel]> { _workouts }
    var workoutsPublisher: Published<[RemoteWorkoutModel]>.Publisher { $workouts }
    
    init(workoutLoader: WorkoutLoader, exerciseLoader: ExerciseLoader) {
        self.workoutLoader = workoutLoader
        self.exerciseLoader = exerciseLoader
    }
    
    func loadWorkouts() async throws {
        workouts = try await workoutLoader.loadAll()
    }
    
    func addNew(_ workout: RemoteWorkoutModel) {
        workouts.insert(workout, at: 0)
    }
    
    func delete(_ workout: RemoteWorkoutModel) {
        workouts.removeAll(where: { $0 == workout })
    }
    func loadExercises(for workout: RemoteWorkoutModel) async throws -> [RemoteExerciseModel] {
        return try await exerciseLoader.loadAll(for: workout)
    }
}

class PreviewWorkoutManager: WorkoutManager {
    @Published var workouts: [RemoteWorkoutModel] = []
    var workoutsPublished: Published<[RemoteWorkoutModel]> { _workouts }
    var workoutsPublisher: Published<[RemoteWorkoutModel]>.Publisher { $workouts }
    
    func loadWorkouts() async throws {
        
    }
    
    func addNew(_ workout: RemoteWorkoutModel) {
        workouts.append(workout)
    }
    
    func delete(_ workout: RemoteWorkoutModel) {
        
    }
    func loadExercises(for workout: RemoteWorkoutModel) async throws -> [RemoteExerciseModel] {
        return []
    }
    
}
