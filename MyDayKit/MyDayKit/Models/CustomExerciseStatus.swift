//
//  CustomExerciseStatus.swift
//  MyDayKit
//
//  Created by Findlay Wood on 25/10/2026.
//

import Foundation

/// Where a custom exercise stands in review.
///
/// **Only the server writes it.** The dashboards set it on the top-level
/// `CustomExercises/{id}` copy, and a Cloud Function mirrors it onto the
/// creator's `Users/{uid}/CustomExercises/{id}`. The app reads it and never
/// encodes it (see `CustomExercise.encode(to:)`), and the rules reject any
/// client write that changes it.
///
/// **The creator is shown two states, not four.** `rejected` and `duplicate`
/// only mean the exercise will not join the catalogue — it stays theirs, logs
/// and templates intact — so they read exactly as an exercise that is simply
/// the user's own, with no verdict. `isInReview` and `isInCatalogue` are the
/// only questions the app asks of it.
public enum CustomExerciseStatus: String, Codable, Sendable {
    case pending
    case approved
    case rejected
    case duplicate

    /// Shown as "In review".
    var isInReview: Bool { self == .pending }

    /// Shown as "Added to the catalogue". The catalogue then holds the same
    /// id, so the picker shows the catalogue's copy instead.
    var isInCatalogue: Bool { self == .approved }
}
