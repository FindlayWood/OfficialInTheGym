//
//  Exercise.swift
//  MyDayKit
//
//  Created by Findlay Wood on 05/08/2025.
//

import Foundation

/// One exercise from the `Exercises` catalogue, as the picker offers it and as
/// every logged exercise stores it.
///
/// **`muscleGroups` and `movementPatterns` are the body parts and are optional.**
/// The catalogue has carried both for a long time: they are ids into the
/// `MuscleGroups` and `MovementTypes` collections, and the DailyTotals Cloud
/// Function reads them from `Exercises/{id}` to split each day's volume into
/// training balance. Before this the app decoded only id, name and category, so
/// what the exercise worked was dropped on the way in.
/// `category` is the broad region the picker filters on; the muscle groups are
/// the detail beneath it. One does not replace the other.
///
/// **Neither may become non-optional.** An `Exercise` is embedded in every day
/// file and day document through `MyDayExerciseModel.exercise`, and none
/// written before this carries either key — a required field would stop every
/// one of those days decoding (see *Workout Library Loading* in CLAUDE.md). A
/// catalogue exercise nobody has tagged yet has neither, too.
///
/// **`isCompound` and `isUnilateral` are optional for the same reason.** The
/// catalogue has carried both since the admin app was built, and a custom
/// exercise is not saved without them (`CustomExercise`), but no day file
/// written before now has either key.
public struct Exercise: Codable, Hashable {
    public let id: String
    /// Public so the composition root can match names for the custom exercise
    /// form (`SimilarExerciseFinder`).
    public let name: String
    let category: ExerciseCategory
    /// Ids from `MuscleGroups` — `chest`, `quads`, `rotator_cuff`.
    let muscleGroups: [String]?
    /// Ids from `MovementTypes` — `hinge`, `push_horizontal`.
    let movementPatterns: [String]?
    /// Works several joints at once — a squat, not a leg extension.
    let isCompound: Bool?
    /// Works one side at a time — a split squat, not a squat.
    let isUnilateral: Bool?

    init(
        id: String,
        name: String,
        category: ExerciseCategory,
        muscleGroups: [String]? = nil,
        movementPatterns: [String]? = nil,
        isCompound: Bool? = nil,
        isUnilateral: Bool? = nil
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.muscleGroups = muscleGroups
        self.movementPatterns = movementPatterns
        self.isCompound = isCompound
        self.isUnilateral = isUnilateral
    }

    static let pressUps = Exercise(
        id: UUID().uuidString,
        name: "Press Up",
        category: .upperBody,
        muscleGroups: ["chest", "triceps", "shoulders"],
        movementPatterns: ["push_horizontal"]
    )
    static let squat = Exercise(
        id: UUID().uuidString,
        name: "Squat",
        category: .lowerBody,
        muscleGroups: ["quads", "glutes"],
        movementPatterns: ["squat"]
    )
}
