//
//  MyDayDaySnapshot.swift
//  MyDayKit
//
//  Created by Findlay Wood on 18/11/2026.
//

import Foundation

/// What a day held at one moment, by id and value, so two moments can be compared
/// (`MyDayScrollTarget.after(_:_:)`).
///
/// **A value copy, never the day itself.** `MyDayExerciseModel` is a class, and saving a set
/// appends to the same instance the previous `selectedDay` held — so the "before" day already
/// contains the new set by the time anyone looks. Copying ids and values out is the only way to
/// still have a before.
struct MyDayDaySnapshot: Equatable {

    struct Exercise: Equatable {
        let id: String
        /// Each set's id and what it holds, so an edited set reads as changed.
        let sets: [Set]
    }

    struct Set: Equatable {
        let id: String
        let values: String
    }

    let dayId: String
    let exercises: [Exercise]
    let workoutIds: [String]
    let sportIds: [String]
    let checkIn: String?
    let rating: String?

    init(_ day: MyDayFullDayModel) {
        dayId = day.id
        exercises = day.exercises.map { exercise in
            Exercise(
                id: exercise.id,
                sets: exercise.completions.map { Set(id: $0.id, values: Self.values(of: $0)) }
            )
        }
        workoutIds = day.workouts.map(\.id)
        sportIds = (day.sports ?? []).map(\.id)
        checkIn = day.wellnessEntry.map { entry in
            [entry.sleepQuality, entry.physicalReadiness, entry.mentalEnergy, entry.overallMood]
                .map { "\($0.rawValue)" }.joined(separator: ",")
        }
        rating = day.rpeEntry.map { "\($0.score)" }
    }

    private static func values(of set: ExerciseCompletions) -> String {
        var parts: [String] = ["\(set.reps)"]
        parts.append(set.weight.map { "\($0)" } ?? "")
        parts.append(set.weightUnit?.rawValue ?? "")
        parts.append(set.time.map { "\($0)" } ?? "")
        parts.append(set.distance.map { "\($0)" } ?? "")
        parts.append(set.distanceUnits?.rawValue ?? "")
        if let tempo = set.tempo {
            parts.append("\(tempo.eccentric)-\(tempo.eccentricHold)-\(tempo.concentric)-\(tempo.concentricHold)")
        } else {
            parts.append("")
        }
        parts.append(set.note ?? "")
        parts.append(set.eachSide.map { "\($0)" } ?? "")
        return parts.joined(separator: "|")
    }
}
