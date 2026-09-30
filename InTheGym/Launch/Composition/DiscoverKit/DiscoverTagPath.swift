//
//  DiscoverTagPath.swift
//  InTheGym
//
//  Created by Findlay Wood on 30/09/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import Foundation

/// **The one definition of the tag directory's paths**, as written by the
/// tag Cloud Functions. The subcollections are `TaggedExercises` /
/// `TaggedWorkouts`, not `Exercises` / `WorkoutTemplates`: the functions find a
/// subject's entries with a collection-group query, and a group named
/// `Exercises` would also match the top-level catalogue.
enum DiscoverTagPath {
    static let tags = "Tags"

    static func taggedExercises(_ tag: String) -> String {
        "\(tags)/\(tag)/TaggedExercises"
    }

    static func taggedWorkouts(_ tag: String) -> String {
        "\(tags)/\(tag)/TaggedWorkouts"
    }
}
