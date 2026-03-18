//
//  DisplayingWorkoutsViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 26/11/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import Combine

class DisplayingWorkoutsViewModel {
    
    // MARK: - Publisher
    @Published var isLoading: Bool = false
    @Published var searchText: String = ""
    @Published var workouts: [WorkoutModel] = []
    var errorFetching = PassthroughSubject<Error,Never>()
    var storedWorkouts: [WorkoutModel] = []
    var filteredWorkouts: [WorkoutModel] = []
    
    var selectedWorkout: WorkoutModel?
    
    var updateListener = WorkoutUpdatedListener()
    
    private var subscriptions = Set<AnyCancellable>()
    
    private var currentSegment: WorkoutSegments = .all
    
    // MARK: - Properties
    var apiService: FirebaseDatabaseManagerService
    
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
    }
    
    // MARK: - Functions
    func initSubscribers() {
        $searchText
            .sink { [weak self] in self?.filterInitialUsers(with: $0)}
            .store(in: &subscriptions)
    }
    
    // MARK: - Fetch Function
    @MainActor
    func fetchWorkouts() {
        isLoading = true
        Task {
            do {
                let models: [WorkoutModel] = try await apiService.fetchAsync()
                let liveWorkouts = models.filter { !$0.completed && $0.startTime != nil }.sorted { $0.startTime ?? 0 > $1.startTime ?? 0 }
                let completedWorkouts = models.filter { $0.completed }.sorted { $0.startTime ?? 0 > $1.startTime ?? 0}
                let notStartedWorkouts = models.filter { $0.startTime == nil }
                let allWorkouts = liveWorkouts + notStartedWorkouts + completedWorkouts
                workouts = allWorkouts
                storedWorkouts = allWorkouts
                isLoading = false
            } catch {
                errorFetching.send(error)
                isLoading = false
            }
        }
    }
    
    func workoutSelected(at indexPath: IndexPath) -> WorkoutModel {
        let currentModels = workouts
        return currentModels[indexPath.row]
    }
    
    func filterInitialUsers(with text: String) {
        if text.isEmpty {
            filteredWorkouts = storedWorkouts.filter { filterForSegment($0)}
            workouts = filteredWorkouts
        } else {
            filteredWorkouts = storedWorkouts.filter { ($0.title.lowercased().contains(text.lowercased()) || filterForExercises($0, text: text)) && filterForSegment($0)}
            workouts = filteredWorkouts
        }
    }
    func switchSegment(to newIndex: Int) {
        switch newIndex {
        case 0:
            currentSegment = .all
        case 1:
            currentSegment = .completed
        case 2:
            currentSegment = .live
        default:
            break
        }
        filterInitialUsers(with: searchText)
    }
    func filterForSegment(_ workout: WorkoutModel) -> Bool {
        switch currentSegment {
        case .all:
            return true
        case .completed:
            return workout.completed
        case .live:
            return workout.liveWorkout ?? false
        }
    }
    func filterForExercises(_ workout: WorkoutModel, text: String) -> Bool {
        for exercise in workout.exercises ?? [] {
            if exercise.exercise.lowercased().contains(text.lowercased()) {
                return true
            } else {
                continue
            }
        }
        return false
    }
    enum WorkoutSegments {
        case all
        case completed
        case live
    }
    
    func deleteWorkout(_ model: WorkoutModel) {
        let deleteWorkoutModel = FirebaseMultiUploadDataPoint(value: nil, path: "Workouts/\(UserDefaults.currentUser.uid)/\(model.id)")
        Task {
            do {
                try await apiService.multiLocationUploadAsync(data: [deleteWorkoutModel])
                print("deleted")
            }
            catch {
                print(String(describing: error))
            }
        }
    }
}


