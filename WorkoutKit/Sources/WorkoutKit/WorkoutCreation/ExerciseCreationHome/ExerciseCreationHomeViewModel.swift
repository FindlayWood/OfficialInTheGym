//
//  File.swift
//  
//
//  Created by Findlay-Personal on 23/04/2023.
//

import Combine
import Foundation

class ExerciseCreationHomeViewModel: ObservableObject {
    
    var coordinator: CreationCoordinator?
    
    @Published var page: Int = 0
    @Published var exercises: [String] = ["Bench Press", "Squats", "Pull ups", "Bicep Curls", "Lunge"]
    
    @Published var name: String = ""
    @Published var sets: Int = 1
    @Published var setModels: [SetModel] = []
    
    @Published var selectedSetModel: SetModel?
    @Published var selectedReps: Int = 1
    
    @Published var units: Double = 0
    
    private var subscriptions = Set<AnyCancellable>()
    
    private var workoutViewModel: WorkoutCreationHomeViewModel
    
    init(workoutViewModel: WorkoutCreationHomeViewModel) {
        self.workoutViewModel = workoutViewModel
        setListener()
        repsListener()
    }
    
    func setListener() {
        $sets
            .sink { [weak self] in self?.initNewSetModels($0) }
            .store(in: &subscriptions)
    }
    func repsListener() {
        $selectedReps
            .sink { [weak self] in self?.selectedRepsChanged($0) }
            .store(in: &subscriptions)
    }
    func initNewSetModels(_ sets: Int) {
        setModels.removeAll()
        for num in 0..<sets {
            setModels.append(.init(setNumber: num))
        }
    }
    func selectedRepsChanged(_ newValue: Int) {
        if let selectedSetModel {
            if let index = setModels.firstIndex(where: { $0.setNumber == selectedSetModel.setNumber }) {
                setModels[index].reps = newValue
            }
        } else {
            for index in 0..<setModels.count {
                setModels[index].reps = newValue
            }
        }
    }
    func toggleSetSelected(_ set: SetModel) {
        if var selectedModel = selectedSetModel {
            if selectedModel.setNumber == set.setNumber {
                selectedSetModel = nil
            } else {
                selectedSetModel = set
                selectedReps = set.reps
            }
        } else {
            selectedSetModel = set
            selectedReps = set.reps
        }
    }
    func selectedUnitsChanged(_ newValue: Units) {
        
    }
    func updateWeight(_ model: WeightModel) {
        if let selectedSetModel {
            if let index = setModels.firstIndex(where: { $0.setNumber == selectedSetModel.setNumber }) {
                setModels[index].weight = model
            }
        } else {
            for index in 0..<setModels.count {
                setModels[index].weight = model
            }
        }
    }
    
    /// update distance for each set
    /// - Parameter model: distance model containing unit and value
    func updateDistance(_ model: DistanceModel) {
        if let selectedSetModel {
            if let index = setModels.firstIndex(where: { $0.setNumber == selectedSetModel.setNumber }) {
                setModels[index].distance = model
            }
        } else {
            for index in 0..<setModels.count {
                setModels[index].distance = model
            }
        }
    }
    /// update time for each set
    /// - Parameter model: time model containing unit and value
    func updateTime(_ model: TimeModel) {
        if let selectedSetModel {
            if let index = setModels.firstIndex(where: { $0.setNumber == selectedSetModel.setNumber }) {
                setModels[index].time = model
            }
        } else {
            for index in 0..<setModels.count {
                setModels[index].time = model
            }
        }
    }
    /// update rest time for each set
    /// - Parameter model: time model containing unit and value
    func updateRestTime(_ model: TimeModel) {
        if let selectedSetModel {
            if let index = setModels.firstIndex(where: { $0.setNumber == selectedSetModel.setNumber }) {
                setModels[index].restTime = model
            }
        } else {
            for index in 0..<setModels.count {
                setModels[index].restTime = model
            }
        }
    }
    /// update tempo for each set
    /// - Parameter model: tempo model containing unit and value
    func updateTempo(_ model: TempoModel) {
        if let selectedSetModel {
            if let index = setModels.firstIndex(where: { $0.setNumber == selectedSetModel.setNumber }) {
                setModels[index].tempo = model
            }
        } else {
            for index in 0..<setModels.count {
                setModels[index].tempo = model
            }
        }
    }
    
    func clearAll(_ unit: Units) {
        switch unit {
        case .weight:
            for index in 0..<setModels.count {
                setModels[index].weight = nil
            }
        case .distance:
            for index in 0..<setModels.count {
                setModels[index].distance = nil
            }
        case .time:
            for index in 0..<setModels.count {
                setModels[index].time = nil
            }
        case .restime:
            for index in 0..<setModels.count {
                setModels[index].restTime = nil
            }
        case .tempo:
            for index in 0..<setModels.count {
                setModels[index].tempo = nil
            }
        }
    }
    
    // MARK: - Actions
    func addExerciseAction() {
        let exercise = ExerciseModel(id: UUID().uuidString, name: name, workoutPosition: workoutViewModel.exercises.count, type: .upperBody, sets: setModels)
        workoutViewModel.addExercise(exercise)
        coordinator?.popBack()
    }
}
