//
//  DiscoverSubject+Firestore.swift
//  InTheGym
//
//  Created by Findlay Wood on 30/09/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import DiscoverKit
import Foundation

/// **The one definition of where a DISCOVER subject lives in Firestore.** Every
/// adapter that reads or writes engagement — ratings now; comments, likes and
/// tag votes later — derives its path from here, so no adapter re-derives
/// `"WorkoutTemplates/\(id)"` and the two sides of a pipeline cannot drift.
///
/// In the composition root rather than on the framework's `DiscoverSubject`,
/// because a path is infrastructure and the framework holds none.
extension DiscoverSubject {

    /// The subject itself — `Exercises/{id}`, `WorkoutTemplates/{id}`, `Clips/{id}`.
    var documentPath: String {
        switch self {
        case .exercise(let id): return "Exercises/\(id)"
        case .workout(let id): return "WorkoutTemplates/\(id)"
        case .clip(let id): return "Clips/\(id)"
        }
    }

    /// Its server-owned card — `DiscoverExercises/{id}` and so on.
    var cardPath: String {
        switch self {
        case .exercise(let id): return "DiscoverExercises/\(id)"
        case .workout(let id): return "DiscoverWorkouts/\(id)"
        case .clip(let id): return "DiscoverClips/\(id)"
        }
    }

    /// One user's rating — the document id is the user's id, so there is one
    /// rating per user per subject.
    func ratingPath(userId: String) -> String {
        "\(documentPath)/Ratings/\(userId)"
    }

    /// Every comment and reply on the subject, in one collection.
    var commentsPath: String {
        "\(documentPath)/Comments"
    }

    func commentPath(_ commentId: String) -> String {
        "\(commentsPath)/\(commentId)"
    }

    /// One user's tags on the subject — the whole set in one document, so a
    /// user counts once per tag.
    func tagVotePath(userId: String) -> String {
        "\(documentPath)/TagVotes/\(userId)"
    }
}
