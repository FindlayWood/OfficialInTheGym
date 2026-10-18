//
//  MyDayDemoWorkout.swift
//  MyDayKit
//
//  Created by Findlay Wood on 18/10/2026.
//

import Foundation

/// The example workout offered on the welcome screen, before signup.
///
/// Three exercises chosen to show the range of what a set can hold rather
/// than to be a good programme: a loaded lift (kg), a bodyweight one (BW, so
/// the weight card reads as a label rather than a number) and a single-arm
/// one (each side). Three sets apiece is enough to log a couple, edit one and
/// add another without the screen turning into a chore.
///
/// **Built fresh on every call** — new ids each time — so a second try starts
/// clean, and nothing about it is stored anywhere to be read back.
enum MyDayDemoWorkout {

    static let userId = "demo"

    static func entry(at date: Date = Date()) -> DailyWorkoutEntry {
        DailyWorkoutEntry(template: template(at: date), assignedDate: date)
    }

    private static func template(at date: Date) -> WorkoutTemplateModel {
        WorkoutTemplateModel(
            id: UUID().uuidString,
            title: "Full Body Starter",
            description: nil,
            exercises: [
                exercise(
                    "Goblet Squat", category: .lowerBody, at: 0,
                    sets: (0..<3).map { WorkoutSetModel(id: UUID().uuidString, orderIndex: $0, reps: 10, weight: 16, weightUnit: .kg) }
                ),
                exercise(
                    "Push Up", category: .upperBody, at: 1,
                    sets: (0..<3).map { WorkoutSetModel(id: UUID().uuidString, orderIndex: $0, reps: 12, weightUnit: .bw) }
                ),
                exercise(
                    "Dumbbell Row", category: .upperBody, at: 2,
                    sets: (0..<3).map { WorkoutSetModel(id: UUID().uuidString, orderIndex: $0, reps: 10, weight: 14, weightUnit: .kg, eachSide: true) }
                )
            ],
            createdBy: userId,
            isPublic: false,
            tags: nil,
            estimatedDuration: 20,
            difficulty: .beginner,
            createdAt: date,
            updatedAt: date
        )
    }

    private static func exercise(
        _ name: String,
        category: ExerciseCategory,
        at index: Int,
        sets: [WorkoutSetModel]
    ) -> WorkoutExerciseModel {
        WorkoutExerciseModel(
            id: UUID().uuidString,
            exerciseId: UUID().uuidString,
            exerciseName: name,
            exerciseCategory: category,
            orderIndex: index,
            sets: sets,
            // Short on purpose: the rest timer is worth seeing once, but a full
            // minute after every set is a long wait when you are only trying it.
            restSeconds: 20
        )
    }
}
