//
//  AddExerciseTempoViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 29/08/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Combine
import Foundation

class AddExerciseTempoViewModel {
    // MARK: - Publishers
    @Published var eccentric: Int?
    @Published var eccentricPause: Int?
    @Published var concentric: Int?
    @Published var concentricPause: Int?
    
    @Published var valid: Bool = false
    
    var tempoModels: [ExerciseTempoModel] = []
    
    private var subscriptions = Set<AnyCancellable>()
    // MARK: - Initializer
    init() {
        initSubscriptions()
    }
    // MARK: - Methods
    func initSubscriptions() {
        Publishers.CombineLatest4($eccentric, $eccentricPause, $concentric, $concentricPause)
            .map { eccentric, eccentricPause, concentric, concentricPause  in
                eccentric ?? 0 > 0 && eccentricPause != nil && concentric ?? 0 > 0 && concentricPause != nil
            }
            .sink { [weak self] in self?.valid = $0 }
            .store(in: &subscriptions)
            
    }
    
    func initTempoModels(exercise: ExerciseModel) {
        tempoModels = exercise.tempo ?? Array(repeating: .init(eccentric: 0, eccentricPause: 0, concentric: 0, concentricPause: 0), count: exercise.reps?.count ?? 0)
    }
    func updateTempoModels(_ selectedSet: Int?, model: ExerciseTempoModel) {
            if let selectedSet = selectedSet {
                tempoModels[selectedSet] = model
            } else {
                let count = tempoModels.count
                tempoModels = Array(repeating: model, count: count)
            }
        
    }
}
