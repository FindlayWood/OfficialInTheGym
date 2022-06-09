//
//  DisplayCircuitViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 28/04/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import Firebase
import Combine

class DisplayCircuitViewModel{
    // MARK: - Publishers
    @Published var isLoading: Bool = false
    var updateModelPublisher = PassthroughSubject<(CircuitTableModel,IndexPath),Never>()
    var updatedCircuitPublisher: PassthroughSubject<CircuitModel,Never>?
    var completedCircuitPublisher = PassthroughSubject<Void,Never>()
    // MARK: - Properties
    var circuitModel: CircuitModel!
    var workoutModel: WorkoutModel!
    lazy var tableModels: [CircuitTableModel] = circuitModel.intergrate()
    var apiService: FirebaseDatabaseManagerService
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared){
        self.apiService = apiService
    }
    // MARK: - Actions
    func completedExercise(at indexPath: IndexPath){
        var model = tableModels[indexPath.item]
        model.completed = true
        let position = model.exerciseOrder
        let setNumber = model.set - 1
        var exercise = circuitModel.exercises[position]
        exercise.completedSets?[setNumber] = true
        circuitModel.exercises[position] = exercise
        let uploadModel = CircuitDatabaseModel(circuitModel: circuitModel, workoutModel: workoutModel)
        let uploadPoint = uploadModel.getCompletedSetPoint(exercisePosition: position, setNumber: setNumber)
        apiService.multiLocationUpload(data: [uploadPoint]) { [weak self] result in
            guard let self = self else {return}
            switch result {
            case .success(_):
                self.updateStats(for: model)
                self.updateModelPublisher.send((model, indexPath))
                self.updatedCircuitPublisher?.send(self.circuitModel)
            case .failure(_):
                break
            }
        }
    }
    // MARK: - Update Stats
    func updateStats(for exercise: CircuitTableModel) {
        DispatchQueue.global(qos: .background).async {
            let statsUpdateModel = UpdateExerciseSetStatsModel(exerciseName: exercise.exerciseName, reps: exercise.reps, weight: exercise.weight)
            self.apiService.multiLocationUpload(data: statsUpdateModel.points) { [weak self] result in
                switch result {
                case .success(_):
                    statsUpdateModel.checkMax()
                case .failure(_):
                    self?.updateStats(for: exercise)
                }
            }
        }
    }
    // MARK: - Complete Circuit
    func completeCircuit(with rpe: Int){
        isLoading = true
        circuitModel.completed = true
        let uploadModel = CircuitDatabaseModel(circuitModel: circuitModel, workoutModel: workoutModel)
        let points = uploadModel.getCompletedCircuitPoints(rpe: rpe)
        apiService.multiLocationUpload(data: points) { [weak self] result in
            guard let self = self else {return}
            switch result {
            case .success(_):
                self.updatedCircuitPublisher?.send(self.circuitModel)
                self.isLoading = false
                self.completedCircuitPublisher.send(())
            case .failure(_):
                self.completeCircuit(with: rpe)
            }
        }
    }
    // MARK: - Retrieve Functions
    func isInteractionEnabled() -> Bool {
        guard let workoutModel = workoutModel else {
            return false
        }

        if workoutModel.startTime != nil && !workoutModel.completed {
            return true
        } else {
            return false
        }
    }
}
