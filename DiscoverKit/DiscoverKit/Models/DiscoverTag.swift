//
//  DiscoverTag.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 30/09/2026.
//

import Foundation

/// One entry in the tag directory: a tag and how many public exercises and
/// workouts it is visible on. Counts are optional for the reason card counts
/// are — the server writes them.
public struct DiscoverTag: Decodable, Identifiable, Hashable, Sendable {
    public let tag: String
    public let exerciseCount: Int?
    public let workoutCount: Int?
    public let totalCount: Int?

    public var id: String { tag }

    public init(tag: String, exerciseCount: Int? = nil, workoutCount: Int? = nil, totalCount: Int? = nil) {
        self.tag = tag
        self.exerciseCount = exerciseCount
        self.workoutCount = workoutCount
        self.totalCount = totalCount
    }
}
