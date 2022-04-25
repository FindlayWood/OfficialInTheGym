//
//  AddMoreViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 25/04/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import Combine

class AddMoreViewModel {
    
    // MARK: - Publishers
    @Published var setCellModels: [SetCellModel]?
    @Published var isLiveWorkout: Bool = false
    
    // MARK: - Properties
    var selectedSet: Int? = nil
    
    var cellCount: Int? {
        if let cellCount = setCellModels?.count {
            return cellCount - 1
        } else {
            return nil
        }
    }
    
    // MARK: - Actions
    func timeUpdated(_ weight: String) {
        if let selectedSet = selectedSet {
            setCellModels?[selectedSet].weightString = weight
        } else {
            let newModels = setCellModels?.map { SetCellModel(setNumber: $0.setNumber, repNumber: $0.repNumber, weightString: weight) }
            setCellModels = newModels
        }
    }
    func distanceUpdated(_ weight: String) {
        if let selectedSet = selectedSet {
            setCellModels?[selectedSet].weightString = weight
        } else {
            let newModels = setCellModels?.map { SetCellModel(setNumber: $0.setNumber, repNumber: $0.repNumber, weightString: weight) }
            setCellModels = newModels
        }
    }
    func restTimeUpdated(_ weight: String) {
        if let selectedSet = selectedSet {
            setCellModels?[selectedSet].weightString = weight
        } else {
            let newModels = setCellModels?.map { SetCellModel(setNumber: $0.setNumber, repNumber: $0.repNumber, weightString: weight) }
            setCellModels = newModels
        }
    }
    
    // MARK: - Functions
    func getTimeCellModels(from viewModel: ExerciseCreationViewModel) {
        var models = [SetCellModel]()
        guard let reps = viewModel.exercise.reps else {return}
        for (index, rep) in reps.enumerated() {
            let newModel = SetCellModel(setNumber: index + 1, repNumber: rep, weightString: viewModel.exercise.time?[index].description ?? " ")
            models.append(newModel)
        }
        setCellModels = models
        isLiveWorkout = (viewModel.exercisekind == .live)
    }
    func getDistanceCellModels(from viewModel: ExerciseCreationViewModel) {
        var models = [SetCellModel]()
        guard let reps = viewModel.exercise.reps else {return}
        for (index, rep) in reps.enumerated() {
            let newModel = SetCellModel(setNumber: index + 1, repNumber: rep, weightString: viewModel.exercise.distance?[index] ?? " ")
            models.append(newModel)
        }
        setCellModels = models
        isLiveWorkout = (viewModel.exercisekind == .live)
    }
    func getRestTimeCellModels(from viewModel: ExerciseCreationViewModel) {
        var models = [SetCellModel]()
        guard let reps = viewModel.exercise.reps else {return}
        for (index, rep) in reps.enumerated() {
            let newModel = SetCellModel(setNumber: index + 1, repNumber: rep, weightString: viewModel.exercise.restTime?[index].description ?? " ")
            models.append(newModel)
        }
        setCellModels = models
        isLiveWorkout = (viewModel.exercisekind == .live)
    }
    
}
