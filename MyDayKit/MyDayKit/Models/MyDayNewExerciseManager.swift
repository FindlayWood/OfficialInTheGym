//
//  MyDayNewExerciseManager.swift
//  MyDayKit
//
//  Created by Findlay Wood on 27/08/2025.
//

import Foundation

class MyDayNewExerciseManager: ObservableObject, Hashable {
    
    let exercise: Exercise
    @Published var reps: Int?
    @Published var weight: Double?
    @Published var weightUnits: WeightUnit?
    @Published var distance: Double?
    @Published var distanceUnits: DistanceUnit?
    @Published var time: Int?
    @Published var tempo: Tempo?
    @Published var note: String?
    @Published var eachSide: Bool = false
    
    init(exercise: Exercise, reps: Int? = nil, weight: Double? = nil, weightUnits: WeightUnit? = nil) {
        self.exercise = exercise
        self.reps = reps
        self.weight = weight
        self.weightUnits = weightUnits
    }
    
    func isOptionAdded(_ option: ExerciseOptions) -> Bool {
        switch option {
        case .weight:
            return (weight != nil && weightUnits != nil)
        case .distance:
            return (distance != nil && distanceUnits != nil)
        case .time:
            return (time != nil)
        case .tempo:
            return (tempo != nil)
        case .note:
            return (note != nil)
        }
    }
    
    func setReps(_ reps: Int) {
        self.reps = reps
    }
    
    func setWeight(_ weight: Double) {
        self.weight = weight
    }
    
    func setWeightUnits(_ weightUnits: WeightUnit) {
        self.weightUnits = weightUnits
    }
    
    func setDistance(_ distance: Double) {
        self.distance = distance
    }
    
    func setDistanceUnits(_ distanceUnits: DistanceUnit) {
        self.distanceUnits = distanceUnits
    }
    
    func setTime(_ time: Int) {
        self.time = time
    }
    
    func setTempo(_ tempo: Tempo) {
        self.tempo = tempo
    }
    
    func setNote(_ note: String) {
        self.note = note
    }
    
    func clear(_ option: ExerciseOptions) {
        switch option {
        case .weight:
            weight = nil
            weightUnits = nil
        case .distance:
            distance = nil
            distanceUnits = nil
        case .time:
            time = nil
        case .tempo:
            tempo = nil
        case .note:
            note = nil
        }
    }
    
    func getCompletion() -> ExerciseCompletions? {
        guard let reps else { return nil }
        
        let completion = ExerciseCompletions(
            id: UUID().uuidString,
            exercise: exercise,
            reps: reps,
            weight: weight,
            weightUnit: weightUnits,
            dateCompleted: .now,
            distance: distance,
            distanceUnits: distanceUnits,
            time: time,
            tempo: tempo,
            note: note,
            eachSide: eachSide
        )
        
        return completion
    }
    
    func reset() {
        reps = nil
        weight = nil
        weightUnits = nil
    }
    
    // MARK: - Hashable
    static func == (lhs: MyDayNewExerciseManager, rhs: MyDayNewExerciseManager) -> Bool {
        lhs === rhs
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}
