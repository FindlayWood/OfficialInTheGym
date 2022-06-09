//
//  WeightViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 16/06/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import Combine

class WeightSelectionViewModel {
    
    // MARK: - Publishers
    @Published var setCellModels: [SetCellModel]?
    @Published var isLiveWorkout: Bool = false
    @Published var isEditing: Bool = false
    // MARK: - Properties
    var exercise: ExerciseModel!
    var selectedSet: Int? = nil
    var editingSet: Int? = nil
    var cellCount: Int? {
        if let cellCount = setCellModels?.count {
            return cellCount - 1
        } else {
            return nil
        }
    }
    
    // MARK: - Properties
    
    // MARK: - Actions
    func weightUpdated(_ weight: String) {
        if let selectedSet = selectedSet {
            setCellModels?[selectedSet].weightString = weight
        } else {
            let newModels = setCellModels?.map { SetCellModel(setNumber: $0.setNumber, repNumber: $0.repNumber, weightString: weight) }
            setCellModels = newModels
        }
    }
    
    // MARK: - Functions
    func getSetCellModels() {
        var models = [SetCellModel]()
        guard let reps = exercise.reps else {return}
        for (index, rep) in reps.enumerated() {
            let newModel = SetCellModel(setNumber: index + 1, repNumber: rep, weightString: exercise.weight?[index] ?? " ")
            models.append(newModel)
        }
        setCellModels = models
    }
}
