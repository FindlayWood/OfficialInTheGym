//
//  SetSelectionViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 09/05/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import Combine

class SetSelectionViewModel {
    
    // MARK: - Publishers
    @Published var setNumber: Int = 1
    
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - Properties
    var exercise: ExerciseModel!
    
    let navigationTitle: String = "Sets"
    
    // MARK: - Actions
    
    // MARK: - Functions
    func initSubscriptions() {
        $setNumber
            .sink { [unowned self] in self.exercise.sets = $0 }
            .store(in: &subscriptions)
    }
}
