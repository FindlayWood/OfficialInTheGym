//
//  Exercise.swift
//  InTheGym
//
//  Created by Findlay Wood on 02/06/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation

struct ExerciseModel: ExerciseType, Codable, Hashable {
    
    var id: String = UUID().uuidString
    var workoutPosition: Int
    var exercise: String
    var reps: [Int]?
    var weight: [String]?
    var type: bodyType
    var completedSets: [Bool]?
    var sets: Int
    var rpe: Int?
    var time: [Int]?
    var distance: [String]?
    var restTime: [Int]?
    var note: String?
    var tempo: [ExerciseTempoModel]?
    
    init(exercise: String, type: bodyType) {
        self.workoutPosition = 0
        self.exercise = exercise
        self.reps = [Int]()
        self.weight = [String]()
        self.type = type
        self.completedSets = [Bool]()
        self.sets = 0
        self.time = [Int]()
        self.distance = [String]()
        self.restTime = [Int]()
        self.tempo = [ExerciseTempoModel]()
    }
    
    init(workoutPosition: Int) {
        self.workoutPosition = workoutPosition
        self.exercise = ""
        self.reps = [Int]()
        self.weight = [String]()
        self.type = .CU
        self.completedSets = [Bool]()
        self.sets = 0
        self.time = [Int]()
        self.distance = [String]()
        self.restTime = [Int]()
        self.tempo = [ExerciseTempoModel]()
    }
    
    func getSets() -> [ExerciseSet] {
        var setModels = [ExerciseSet]()
        guard let reps = reps, let weight = weight, let completedSets = completedSets else {return setModels}
        for i in 0..<sets {
            setModels.append(ExerciseSet(set: i + 1,
                                         reps: reps[i],
                                         weight: weight[i],
                                         completed: completedSets[i],
                                         time: time?[i],
                                         distance: distance?[i],
                                         restTime: restTime?[i],
                                         tempo: tempo?[i]
                                        ))
        }
        return setModels
    }
}


