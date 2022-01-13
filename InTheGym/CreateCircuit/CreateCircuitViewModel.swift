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
    var exercises = CurrentValueSubject<[ExerciseModel],Never>([])
    
    private var subscriptions = Set<AnyCancellable>()
    
    var workoutViewModel: WorkoutCreationViewModel!
    
    var workoutPosition: Int!
    
    init() {
        initSubscribers()
    }
    func initSubscribers() {
//        $circuitTitle
//            .map { newTitle in
//                return newTitle.count > 0
//            }
//            .sink { [unowned self] titleValid in
//                self.validCircuit = self.exercises.value.count > 0 && titleValid
//            }
//            .store(in: &subscriptions)
        
        Publishers.CombineLatest($circuitTitle, exercises)
            .map({ circuitTitle, exercises in
                return circuitTitle.count > 0 && exercises.count > 0
            })
            .sink { [unowned self] valid in
                self.validCircuit = valid
            }
            .store(in: &subscriptions)
    }
    
    func addCircuit() {
        let newCircuit = CircuitModel(workoutPosition: workoutPosition,
                                      exercises: exercises.value,
                                      completed: false, circuitName: circuitTitle,
                                      createdBy: FirebaseAuthManager.currentlyLoggedInUser.username,
                                      creatorID: FirebaseAuthManager.currentlyLoggedInUser.uid,
                                      integrated: true)
        workoutViewModel.addCircuit(newCircuit)
    }
    
}

extension CreateCircuitViewModel: ExerciseAdding {
    func addExercise(_ exercise: ExerciseModel) {
        var currentExercises = exercises.value
        currentExercises.append(exercise)
        exercises.send(currentExercises)
    }
}

extension CreateCircuitViewModel {
    func updateTitle(with newTitle: String) {
        self.circuitTitle = newTitle
    }
}
