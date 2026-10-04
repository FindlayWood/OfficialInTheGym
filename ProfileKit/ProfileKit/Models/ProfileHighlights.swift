//
//  ProfileHighlights.swift
//  ProfileKit
//
//  Created by Findlay Wood on 04/10/2026.
//
import Foundation

/// A profile's highlights: up to three, and whether the user chose them
/// (`isPinned`) or they are the automatic top three by sets logged.
public struct ProfileHighlights: Equatable, Sendable {
    public static let limit = 3

    public let highlights: [ProfileHighlight]
    public let isPinned: Bool

    public init(highlights: [ProfileHighlight], isPinned: Bool) {
        self.highlights = highlights
        self.isPinned = isPinned
    }
}
