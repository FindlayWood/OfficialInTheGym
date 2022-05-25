//
//  CoachWorkoutsViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 25/05/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import Combine

class CoachWorkoutsViewModel {
    
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
    var navigationTitle: String = "My Workouts"
    
    var apiService: FirebaseDatabaseManagerService
    
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
    }
    
    // MARK: - Functions
    func initSubscribers() {
        $searchText
            .sink { [weak self] in self?.filterWorkouts(with: $0)}
            .store(in: &subscriptions)
    }
    
    // MARK: - Fetch Function
    func fetchWorkouts() {
        isLoading = true
        apiService.fetch(WorkoutModel.self) { [weak self] result in
            guard let self = self else {return}
            switch result {
            case .success(let models):
                self.workouts = models
                self.storedWorkouts = models
                self.filteredWorkouts = models
                self.isLoading = false
            case .failure(let error):
                self.errorFetching.send(error)
                self.isLoading = false
            }
        }
    }
    
    func workoutSelected(at indexPath: IndexPath) -> WorkoutModel {
        let currentModels = workouts
        return currentModels[indexPath.row]
    }
    
    func filterWorkouts(with text: String) {
        if text.isEmpty {
            filteredWorkouts = storedWorkouts.filter { filterForSegment($0)}
            workouts = filteredWorkouts
        } else {
            filteredWorkouts = storedWorkouts.filter { $0.title.lowercased().contains(text.lowercased()) && filterForSegment($0)}
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
        filterWorkouts(with: searchText)
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
    enum WorkoutSegments {
        case all
        case completed
        case live
    }
}
