//
//  CreateEMOMViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 16/09/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import Combine

class CreateEMOMViewModel {
    
    // MARK: - Properties
    var navigationTitle = "Create EMOM"
    
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Publishers
    @Published var exercises: [ExerciseModel] = []
    @Published var emomTimeLimit: Int = 10
    @Published var validEmom: Bool = false
    
    var completedPublisher: PassthroughSubject<EMOMModel,Never>?
    var exerciseAddedPublisher = PassthroughSubject<ExerciseModel,Never>()
    
    // MARK: - Actions
    func addEMOM() {
        let newEmom = EMOMModel(emomPosition: 0,
                                workoutPosition: 0,
                                exercises: exercises,
                                timeLimit: (emomTimeLimit * 60),
                                completed: false,
                                started: false)
        completedPublisher?.send(newEmom)
    }
    
    func initSubscribers() {
        
        exerciseAddedPublisher
            .sink { [weak self] in self?.addExercise($0)}
            .store(in: &subscriptions)
        
        $exercises
            .map { $0.count > 0 }
            .sink { [weak self] in self?.validEmom = $0 }
            .store(in: &subscriptions)
    }
}
extension CreateEMOMViewModel {
    func addExercise(_ exercise: ExerciseModel) {
        exercises.append(exercise)
    }
}
