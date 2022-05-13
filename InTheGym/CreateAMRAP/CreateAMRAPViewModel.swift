//
//  CreateAMRAPViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 10/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import Combine

class CreateAMRAPViewModel {
    
    // MARK: - Publishers
    @Published var exercises: [ExerciseModel] = []
    @Published var validAmrap: Bool = false
    @Published var timeLimit: Int = 10
    
    var completedPublisher: PassthroughSubject<AMRAPModel,Never>?
    
    var exerciseAddedPublisher = PassthroughSubject<ExerciseModel,Never>()
    
    // MARK: - Properties
    
    private var subscriptions = Set<AnyCancellable>()
    
    let navigationTitle: String = "Create AMRAP"
    
    // MARK: - Actions
    func addAMRAP() {
        let newAMRAP = AMRAPModel(amrapPosition: 0,
                                  workoutPosition: 0,
                                  timeLimit: (timeLimit * 60),
                                  exercises: exercises,
                                  completed: false,
                                  roundsCompleted: 0,
                                  exercisesCompleted: 0,
                                  started: false)
        completedPublisher?.send(newAMRAP)
    }
    
    func initSubscribers() {
        $exercises
            .map { $0.count > 0 }
            .sink { [weak self] in self?.validAmrap = $0 }
            .store(in: &subscriptions)
        
        exerciseAddedPublisher
            .sink { [weak self] in self?.addExercise($0)}
            .store(in: &subscriptions)
    }
    
}

extension CreateAMRAPViewModel {
    func addExercise(_ exercise: ExerciseModel) {
        exercises.append(exercise)
    }
}
