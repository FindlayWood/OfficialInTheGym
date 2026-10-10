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
        case .match: "Welcome to the match tracker. Here you can record all of your matches/games/competitions."
        case .practice: "Welcome to the practice tracker. Here you can record all of your practice sessions. (Do not record gym sessions here if you have entered them already)"
        }
    }

    var newEntryIntro: String {
        switch self {
        case .match: "Enter some details about your match below. Most important is to rate your performance honestly. We will then calculate other data to show you."
        case .practice: "Enter some details about your practice session below. Most important is to rate your performance honestly. We will then calculate other data to show you."
        }
    }

    var recordButtonTitle: String {
        switch self {
        case .match: "Record New Match"
        case .practice: "Record New Practice"
        }
    }

    var newSectionHeader: String {
        switch self {
        case .match: "New Match"
        case .practice: "New Practice"
        }
    }

    var previousHeader: String {
        switch self {
        case .match: "Previous Matches"
        case .practice: "Previous Practice Sessions"
        }
    }

    var emptyMessage: String {
        switch self {
        case .match: "No previous matches."
        case .practice: "No previous practice sessions."
        }
    }

    var iconName: String {
        switch self {
        case .match: "contest_icon"
        case .practice: "circuit_icon"
        }
    }

    var buttonIconName: String {
        switch self {
        case .match: "match_icon"
        case .practice: "circuit_icon"
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
