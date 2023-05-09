//
//  File.swift
//  
//
//  Created by Findlay-Personal on 08/05/2023.
//

import Foundation

protocol WorkoutManager {
    var workouts: [RemoteWorkoutModel] { get }
    var workoutsPublished: Published<[RemoteWorkoutModel]> { get }
    var workoutsPublisher: Published<[RemoteWorkoutModel]>.Publisher { get }
    func loadWorkouts() async throws
    func addNew(_ workout: RemoteWorkoutModel)
    func delete(_ workout: RemoteWorkoutModel)
    func loadExercises(for workout: RemoteWorkoutModel) async throws -> [RemoteExerciseModel]
}

// MARK: - Remote
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
        Task {
            do {
                try await workoutLoader.writeNew(workout)
            } catch {
                print("Failed to upload new workout -> \(String(describing: error))")
            }
        }
    }
    
    func delete(_ workout: RemoteWorkoutModel) {
        workouts.removeAll(where: { $0 == workout })
    }
    func loadExercises(for workout: RemoteWorkoutModel) async throws -> [RemoteExerciseModel] {
        return try await exerciseLoader.loadAll(for: workout)
    }
}

// MARK: - Preview
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
