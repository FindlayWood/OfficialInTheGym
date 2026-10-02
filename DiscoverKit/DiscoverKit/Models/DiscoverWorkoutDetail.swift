//
//  DiscoverWorkoutDetail.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 02/10/2026.
//

import Foundation

/// A public workout's contents, as its DISCOVER page shows them — read from
/// the full template only when that page opens, since a list card carries no
/// exercises.
///
/// DiscoverKit's own model, not MyDayKit's `WorkoutTemplateModel`: the page
/// shows names and a summary of each exercise's sets, nothing it would edit or
/// perform, and DiscoverKit imports no other framework. The composition root
/// maps one to the other.
public struct DiscoverWorkoutDetail: Hashable, Sendable {
    public let templateId: String
    public let title: String
    public let description: String?
    public let createdBy: String?
    public let exercises: [DiscoverWorkoutExercise]

    public init(templateId: String, title: String, description: String?, createdBy: String?, exercises: [DiscoverWorkoutExercise]) {
        self.templateId = templateId
        self.title = title
        self.description = description
        self.createdBy = createdBy
        self.exercises = exercises
    }
}
