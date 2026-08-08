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
    @Published var clips: [MyDayClipModel]
    
    enum CodingKeys: String, CodingKey {
        case id, date, exercise, completions, clips
    }
    
    init(id: String, date: Date, exercise: Exercise, completions: [ExerciseCompletions], clips: [MyDayClipModel]) {
        self.id = id
        self.date = date
        self.exercise = exercise
        self.completions = completions
        self.clips = clips
    }
    
    // Codable conformance
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        date = try container.decode(Date.self, forKey: .date)
        exercise = try container.decode(Exercise.self, forKey: .exercise)
        completions = try container.decode([ExerciseCompletions].self, forKey: .completions)
        clips = try container.decodeIfPresent([MyDayClipModel].self, forKey: .clips) ?? []
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(date, forKey: .date)
        try container.encode(exercise, forKey: .exercise)
        try container.encode(completions, forKey: .completions)
        try container.encode(clips, forKey: .clips)
    }
}

struct ExerciseCompletions: Identifiable, Codable {
    let id: String
    let exercise: Exercise
    let reps: Int
    let weight: Double?
    let weightUnit: WeightUnit?
    let dateCompleted: Date
    let distance: Double?
    let distanceUnits: DistanceUnit?
    let time: Int?
    let tempo: Tempo?
    let note: String?
    let eachSide: Bool?
    
    func getStats() -> ExerciseStatsSaveModel {
        ExerciseStatsSaveModel(
            id: id,
            exerciseID: exercise.id,
            exerciseName: exercise.name,
            dateComplete: dateCompleted,
            reps: reps,
            weight: WeightUnit.kilograms(weight, unit: weightUnit),
            time: time ?? 0
        )
    }
}

public struct MyDayFullDayModel: Identifiable, Codable {
    public let id: String
    let date: Date
    var exercises: [MyDayExerciseModel]
    var workouts: [DailyWorkoutEntry]
    var rpeEntry: RPEEntry?
    var wellnessEntry: WellnessEntry?
}

struct MyDayClipModel: Identifiable, Codable {
    let id: String
    let clipID: String
    let exerciseID: String
    let dateUploaded: Date
    let thumbnailURL: URL?
}
