//
//  WorkoutExerciseSetManager.swift
//  MyDayKit
//
//  Created by Findlay Wood on 04/06/2026.
//

import Foundation

class WorkoutExerciseSetManager: ObservableObject, Identifiable {
    let id: String
    @Published var reps: Int?
    @Published var weight: Double?
    @Published var weightUnits: WeightUnit?
    @Published var distance: Double?
    @Published var distanceUnits: DistanceUnit?
    @Published var time: Int?
    @Published var tempo: Tempo?
    @Published var note: String?
    @Published var eachSide: Bool = false
    
    init(id: String = UUID().uuidString) {
        self.id = id
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
        objectWillChange.send()
    }
}
