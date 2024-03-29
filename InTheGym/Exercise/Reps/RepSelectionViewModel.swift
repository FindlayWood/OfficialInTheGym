//
//  RepSelectionViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 23/04/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation

class RepSelectionViewModel {
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
    // MARK: - Actions
    func repSelected(_ rep: Int) {
        if let selectedSet = selectedSet {
            setCellModels?[selectedSet].repNumber = rep
        } else {
            let newModels = setCellModels?.map { SetCellModel(setNumber: $0.setNumber, repNumber: rep, weightString: " ") }
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
