//
//  TrackedSessionKind.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import Foundation

/// Match Tracker and Practice Tracker, which are one tool.
///
/// The legacy app had two copies of every file, identical apart from what is
/// collected here: the copy, the icons, and how much load a session logs. A
/// practice asks for its RPE and duration; a match logs a flat 1000 at RPE 10
/// over two hours. **Everything else is shared and must stay shared**: two
/// copies of the trackers had already drifted, in the rating headers of the
/// new-match sheet.
///
/// `@frozen` because PerformanceKit builds with library evolution.
@frozen
public enum TrackedSessionKind: Sendable {
    case match
    case practice

    var title: String {
        switch self {
        case .match: "Match Tracker"
        case .practice: "Practice Tracker"
        }
    }

    var detailTitle: String {
        switch self {
        case .match: "Match Detail"
        case .practice: "Practice Detail"
        }
    }

    var newEntryTitle: String {
        switch self {
        case .match: "New Match"
        case .practice: "New Practice Session"
        }
    }

    var welcome: String {
        switch self {
        case .match: "Rate every match, game or competition, with a snapshot of your training going into it."
        case .practice: "Rate every practice session. Gym sessions you already log in MyDay do not belong here."
        }
    }

    var newEntryIntro: String {
        switch self {
        case .match: "Rate how it went, honestly. Your workload going into it is saved alongside."
        case .practice: "Rate how it went, honestly. Your workload going into it is saved alongside."
        }
    }

    var recordButtonTitle: String {
        switch self {
        case .match: "Record Match"
        case .practice: "Record Practice"
        }
    }

    var previousHeader: String {
        switch self {
        case .match: "Matches"
        case .practice: "Practice Sessions"
        }
    }

    var emptyMessage: String {
        switch self {
        case .match: "No matches recorded yet."
        case .practice: "No practice sessions recorded yet."
        }
    }

    /// Only a practice asks how hard it was and how long it lasted.
    var asksForRPEAndDuration: Bool {
        self == .practice
    }

    /// The load a session adds to the workload log, linked to it by
    /// `workoutID`. The legacy rules, unchanged: a match is a flat 1000 at RPE
    /// 10 over 7200 seconds, with `customAddedWorkload` written as 0; a
    /// practice is `duration × RPE × 1.5`, truncated, with no custom field.
    func workload(sessionId: String, endTime: Date, rpe: Int, durationMinutes: Double) -> Workload {
        switch self {
        case .match:
            Workload(id: "", endTime: endTime, rpe: 10, timeToComplete: 7200, workload: 0,
                     customAddedWorkload: 0, matchWorkload: 1000, workoutID: sessionId)
        case .practice:
            Workload(id: "", endTime: endTime, rpe: rpe, timeToComplete: Int(durationMinutes) * 60, workload: 0,
                     practiceWorkload: Int(durationMinutes * Double(rpe) * 1.5), workoutID: sessionId)
        }
    }
}
