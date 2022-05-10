//
//  CreateCircuitViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 02/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import Combine

class CreateCircuitViewModel {
    
    // MARK: - Publishers
    @Published var circuitTitle: String = ""
    @Published var validCircuit: Bool = false
    @Published var exercises: [ExerciseModel] = []
    
    var completedPublisher: PassthroughSubject<CircuitModel,Never>?
    
    var addedExercisePublisher = PassthroughSubject<ExerciseModel,Never>()
    
    private var subscriptions = Set<AnyCancellable>()
    
    let navigationTitle: String = "Create Circuit"

    func initSubscribers() {
        
        Publishers.CombineLatest($circuitTitle, $exercises)
            .map({ circuitTitle, exercises in
                return circuitTitle.count > 0 && exercises.count > 0
            })
            .sink { [unowned self] valid in
                self.validCircuit = valid
            }
            .store(in: &subscriptions)
        
        addedExercisePublisher
            .sink { [weak self] in self?.addExercise($0)}
            .store(in: &subscriptions)
    }
    
    func addCircuit() {
        let newCircuit = CircuitModel(circuitPosition: 0,
                                      workoutPosition: 0,
                                      exercises: exercises,
                                      completed: false,
                                      circuitName: circuitTitle,
                                      createdBy: UserDefaults.currentUser.username,
                                      creatorID: UserDefaults.currentUser.uid,
                                      integrated: true)
        
        completedPublisher?.send(newCircuit)
    }
    
}

extension CreateCircuitViewModel {
    func addExercise(_ exercise: ExerciseModel) {
        exercises.append(exercise)
    }
}

extension CreateCircuitViewModel {
    func updateTitle(with newTitle: String) {
        self.circuitTitle = newTitle
    }
}
