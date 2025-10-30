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
    @Published var weight: Int?
    @Published var weightUnits: WeightUnit?
    @Published var distance: Int?
    @Published var distanceUnits: DistanceUnit?
    
    init(exercise: Exercise, reps: Int? = nil, weight: Int? = nil, weightUnits: WeightUnit? = nil) {
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
        default:
            return false
        }
    }
    
    func setReps(_ reps: Int) {
        self.reps = reps
    }
    
    func setWeight(_ weight: Int) {
        self.weight = weight
    }
    
    func setWeightUnits(_ weightUnits: WeightUnit) {
        self.weightUnits = weightUnits
    }
    
    func setDistance(_ distance: Int) {
        self.distance = distance
    }
    
    func setDistanceUnits(_ distanceUnits: DistanceUnit) {
        self.distanceUnits = distanceUnits
    }
    
    func getCompletion() -> ExerciseCompletions? {
        guard let reps else { return nil }
        
        let completion = ExerciseCompletions(
            id: UUID().uuidString,
            exercise: exercise,
            reps: reps,
            weight: weight,
            weightUnit: weightUnits,
            dateCompleted: .now
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
