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
    @Published var isEditing: Bool = false
    
    var timeUpdatedPublisher: PassthroughSubject<[Int]?,Never>?
    var distanceUpdatedPublisher: PassthroughSubject<[String]?,Never>?
    var restTimeUpdatedPublisher: PassthroughSubject<[Int]?,Never>?
    var noteUpdatedPublisher: PassthroughSubject<String,Never>?
    
    // MARK: - Properties
    var selectedSet: Int? = nil
    var editingSet: Int? = nil
    
    var exercise: ExerciseModel!
    
    var isLive: Bool = false
    
    var cellCount: Int? {
        if let cellCount = setCellModels?.count {
            return cellCount - 1
        } else {
            return nil
        }
    }
    
    // MARK: - Actions
    func timeUpdated(_ time: String) {
        if let selectedSet = selectedSet {
            setCellModels?[selectedSet].weightString = time
        } else {
            let newModels = setCellModels?.map { SetCellModel(setNumber: $0.setNumber, repNumber: $0.repNumber, weightString: time) }
            setCellModels = newModels
        }
    }
    func timeAdded() {
        let times = setCellModels?.map { Int($0.weightString) ?? 0 }
        timeUpdatedPublisher?.send(times)
    }
    func distanceUpdated(_ weight: String) {
        if let selectedSet = selectedSet {
            setCellModels?[selectedSet].weightString = weight
        } else {
            let newModels = setCellModels?.map { SetCellModel(setNumber: $0.setNumber, repNumber: $0.repNumber, weightString: weight) }
            setCellModels = newModels
        }
    }
    func distanceAdded() {
        let distances = setCellModels?.map { $0.weightString }
        distanceUpdatedPublisher?.send(distances)
    }
    func restTimeUpdated(_ weight: String) {
        if let selectedSet = selectedSet {
            setCellModels?[selectedSet].weightString = weight
        } else {
            let newModels = setCellModels?.map { SetCellModel(setNumber: $0.setNumber, repNumber: $0.repNumber, weightString: weight) }
            setCellModels = newModels
        }
    }
    func restTimeAdded() {
        let times = setCellModels?.map { Int($0.weightString) ?? 0 }
        restTimeUpdatedPublisher?.send(times)
    }
    func noteAdded(_ note: String) {
        noteUpdatedPublisher?.send(note)
    }
    // MARK: - Functions
    func getTimeCellModels() {
        var models = [SetCellModel]()
        guard let reps = exercise.reps else {return}
        for (index, rep) in reps.enumerated() {
            let newModel = SetCellModel(setNumber: index + 1, repNumber: rep, weightString: exercise.time?[index].description ?? " ")
            models.append(newModel)
        }
        setCellModels = models
        isLiveWorkout = isLive
    }
    func getDistanceCellModels() {
        var models = [SetCellModel]()
        guard let reps = exercise.reps else {return}
        for (index, rep) in reps.enumerated() {
            let newModel = SetCellModel(setNumber: index + 1, repNumber: rep, weightString: exercise.distance?[index] ?? " ")
            models.append(newModel)
        }
        setCellModels = models
        isLiveWorkout = isLive
    }
    func getRestTimeCellModels() {
        var models = [SetCellModel]()
        guard let reps = exercise.reps else {return}
        for (index, rep) in reps.enumerated() {
            let newModel = SetCellModel(setNumber: index + 1, repNumber: rep, weightString: exercise.restTime?[index].description ?? " ")
            models.append(newModel)
        }
        setCellModels = models
        isLiveWorkout = isLive
    }
    
}
