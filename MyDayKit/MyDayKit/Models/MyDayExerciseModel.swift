//
//  MyDayExerciseModel.swift
//  MyDayKit
//
//  Created by Findlay Wood on 27/07/2025.
//

import Foundation

class MyDayExerciseModel: Identifiable, ObservableObject, Codable {
    let id: String
    let date: Date
    let exercise: Exercise
    @Published var completions: [ExerciseCompletions]
    let clips: [MyDayClipModel] = []
    
    enum CodingKeys: String, CodingKey {
        case id, date, exercise, completions
    }
    
    init(id: String, date: Date, exercise: Exercise, completions: [ExerciseCompletions]) {
        self.id = id
        self.date = date
        self.exercise = exercise
        self.completions = completions
    }
    
    // Codable conformance
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        date = try container.decode(Date.self, forKey: .date)
        exercise = try container.decode(Exercise.self, forKey: .exercise)
        completions = try container.decode([ExerciseCompletions].self, forKey: .completions)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(date, forKey: .date)
        try container.encode(exercise, forKey: .exercise)
        try container.encode(completions, forKey: .completions)
    }
}

struct ExerciseCompletions: Identifiable, Codable {
    let id: String
    let exercise: Exercise
    let reps: Int
    let weight: Int?
    let weightUnit: WeightUnit?
    let dateCompleted: Date
    let distance: Int?
    let distanceUnits: DistanceUnit?
    let time: Int?
    let tempo: Tempo?
    let note: String?
    let eachSide: Bool?
    
    func getStats() -> ExerciseStatsSaveModel {
        var w: Double = 0
        if weightUnit == .kg {
            w = Double(weight ?? 0)
        }
        if weightUnit == .lbs {
            w = Double(weight ?? 0) * 0.453592
        }
        return ExerciseStatsSaveModel(
            id: UUID().uuidString,
            exerciseID: exercise.id,
            exerciseName: exercise.name,
            dateComplete: dateCompleted,
            reps: reps,
            weight: w,
            time: time ?? 0
        )
    }
}

public struct MyDayFullDayModel: Identifiable, Codable {
    public let id: String
    let date: Date
    var exercises: [MyDayExerciseModel]
}

struct MyDayClipModel: Identifiable, Codable {
    let id: String
    let dateRecorded: Date
    let completionID: String
    let url: URL
}
