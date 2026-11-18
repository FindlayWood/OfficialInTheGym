//
//  MyDayScrollTarget.swift
//  MyDayKit
//
//  Created by Findlay Wood on 18/11/2026.
//

import Foundation

/// What the MyDay home brings to the middle of the screen after a save: **whatever was just added
/// or filled in.** A new exercise's card, a new or edited set (its card centred, the set centred in
/// the card's row), a workout or sport added to the day, or the check-in or rating just given.
///
/// Worked out by comparing the day before and after (`after(_:_:)`), never by each action saying
/// where it went: every save on the screen lands on `MyDayManager.selectedDay`, so one comparison
/// covers adding from the logging flow, Repeat Set, editing a set and the check-in cards alike,
/// and a new way of adding gets it for free.
enum MyDayScrollTarget: Equatable {
    case exercise(id: String)
    case set(exerciseId: String, setId: String)
    case workout(id: String)
    case sport(id: String)
    case checkIn
    case rating

    /// The id of the row the home screen scrolls to the middle.
    var rowId: String {
        switch self {
        case .exercise(let id), .set(let id, _): "exercise-\(id)"
        case .workout(let id): "workout-\(id)"
        case .sport(let id): "sport-\(id)"
        case .checkIn: "checkIn"
        case .rating: "rating"
        }
    }

    /// The set to centre inside its card's row, for a set target.
    var setId: String? {
        if case .set(_, let setId) = self { return setId }
        return nil
    }

    /// What changed between two moments of the **same** day. `nil` when nothing was added or
    /// filled in, when there was no before (the day loading), or when the day itself changed —
    /// moving along the date strip must not scroll anything.
    ///
    /// Removals point nowhere: the thing is gone. Only the first change found is returned, in the
    /// order below; one save makes one change.
    static func after(_ old: MyDayDaySnapshot?, _ new: MyDayDaySnapshot) -> MyDayScrollTarget? {
        guard let old, old.dayId == new.dayId else { return nil }

        let oldExercises = Dictionary(old.exercises.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        for exercise in new.exercises {
            guard let before = oldExercises[exercise.id] else {
                return .exercise(id: exercise.id)
            }
            let beforeSets = Dictionary(before.sets.map { ($0.id, $0.values) }, uniquingKeysWith: { first, _ in first })
            if let changed = exercise.sets.first(where: { beforeSets[$0.id] != $0.values }) {
                return .set(exerciseId: exercise.id, setId: changed.id)
            }
        }
        if let workout = new.workoutIds.first(where: { !old.workoutIds.contains($0) }) {
            return .workout(id: workout)
        }
        if let sport = new.sportIds.first(where: { !old.sportIds.contains($0) }) {
            return .sport(id: sport)
        }
        if new.rating != nil, new.rating != old.rating { return .rating }
        if new.checkIn != nil, new.checkIn != old.checkIn { return .checkIn }
        return nil
    }
}
