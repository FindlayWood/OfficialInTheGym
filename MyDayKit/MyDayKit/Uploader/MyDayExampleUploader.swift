//
//  MyDayExampleUploader.swift
//  MyDayKit
//
//  Created by Findlay Wood on 07/02/2026.
//

import Foundation

public struct MyDayExampleLoader: MyDayLoader {
    
    public init() {}
    
    public func load<T>(for date: Date) async throws -> T? where T : Decodable, T : Encodable {

        // Build example model
        let model = exampleFullDay    // from above

        // Encode → Data
        let data = try JSONEncoder().encode(model)

        // Decode into whatever type T requested
        let decoded = try JSONDecoder().decode(T.self, from: data)

        return decoded
    }
}


let exampleFullDay: MyDayFullDayModel = {
    let date = Date()

    // Example exercise 1
    let completion1 = ExerciseCompletions(
        id: UUID().uuidString,
        exercise: .pressUps,
        reps: 12,
        weight: nil,
        weightUnit: nil,
        dateCompleted: date,
        distance: nil,
        distanceUnits: nil,
        time: nil,
        tempo: nil,
        note: "Felt good",
        eachSide: false
    )

    let exercise1 = MyDayExerciseModel(
        id: UUID().uuidString,
        date: date,
        exercise: .pressUps,
        completions: [completion1],
        clips: []
    )

    // Example exercise 2
    let completion2 = ExerciseCompletions(
        id: UUID().uuidString,
        exercise: .squat,
        reps: 10,
        weight: 60,
        weightUnit: .kg,
        dateCompleted: date,
        distance: nil,
        distanceUnits: nil,
        time: nil,
        tempo: nil,
        note: "Heavy!",
        eachSide: false
    )

    let exercise2 = MyDayExerciseModel(
        id: UUID().uuidString,
        date: date,
        exercise: .squat,
        completions: [completion2],
        clips: [
            MyDayClipModel(
                id: UUID().uuidString,
                clipID: "810FB504-DADF-4E76-9B6E-89A1FE2DC827",
                exerciseID: Exercise.squat.id,
                dateUploaded: date,
                thumbnailURL: URL(string: "https://firebasestorage.googleapis.com:443/v0/b/inthegym-2353b.appspot.com/o/TestClipThumbnails%2FfZKSEr4e6yWdYqt0P6BXbnyg1pf2%2F810FB504-DADF-4E76-9B6E-89A1FE2DC827?alt=media&token=59c6f5f7-a153-4c5b-ab16-aa8c7bf8f56a")
            )
        ]
    )

    return MyDayFullDayModel(
        id: UUID().uuidString,
        date: date,
        exercises: [exercise1, exercise2],
        workouts: []
    )
}()
