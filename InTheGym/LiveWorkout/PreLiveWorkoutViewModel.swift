//
//  PreLiveWorkoutViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 01/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import Combine

class PreLiveWorkoutViewModel {
    
    // MARK: - Publishers
    @Published var title: String = ""
    @Published var canContinue: Bool = false
    @Published var isLoading: Bool = false
    var workoutPublisher = PassthroughSubject<WorkoutModel,Never>()
    
    // MARK: - Properties
    var apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared
    
    private let separator = " - "
    
    var suggestions = ["Session", "Lower Session", "Upper Session", "Mixed Session", "Recovery Session"]
    
    var numberOfItems: Int {
        return suggestions.count
    }
    
    private var subscriptions = Set<AnyCancellable>()
    
    var navBarButtonTitle: String = "Continue"
    
    var navigationTitle: String = "Live Workout Title"
    
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
        initSubscriptions()
    }
    
    // MARK: - Actions
    
    func startLiveWorkout() {
        isLoading = true
        let newLiveWorkout = LiveWorkoutModel(id: UUID().uuidString,
                                              title: title,
                                              creatorID: UserDefaults.currentUser.uid,
                                              assignedTo: UserDefaults.currentUser.uid,
                                              isPrivate: false,
                                              completed: false,
                                              liveWorkout: true,
                                              startTime: Date().timeIntervalSince1970)
        
        
        apiService.uploadTimeOrderedModel(model: newLiveWorkout) { [weak self] result in
            switch result {
            case .success(let model):
                let newWorkoutModel = WorkoutModel(liveModel: model)
                self?.workoutPublisher.send(newWorkoutModel)
                self?.isLoading = false
            case .failure(let error):
                print(error)
                self?.isLoading = false
            }
        }
    }
    
    // MARK: - Functions
    
    func initSubscriptions() {
        
        $title
            .map { return $0.count > 0 }
            .sink { [unowned self] in self.canContinue = $0 }
            .store(in: &subscriptions)
    }
    
    func getData(at indexPath: IndexPath) -> String {
        let weekDay = getDay()
        return weekDay + separator + suggestions[indexPath.row]
    }
    
    func getDay() -> String {
        let date = Date()
        return date.getDayOfWeek()
    }
    
    func updateTitle(with newTitle: String) {
        self.title = newTitle
    }

}
