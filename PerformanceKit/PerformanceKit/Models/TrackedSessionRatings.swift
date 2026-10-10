//
//  TrackedSessionRatings.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import Foundation

/// How the athlete rated a match or practice, each 0–10. Every rating starts at
/// 5 on a new entry, as the legacy sheet did.
public struct TrackedSessionRatings: Equatable, Sendable {
    public var overall: Int
    public var technical: Int
    public var tactical: Int
    public var physical: Int
    public var mental: Int

    public init(overall: Int = 5, technical: Int = 5, tactical: Int = 5, physical: Int = 5, mental: Int = 5) {
        self.overall = overall
        self.technical = technical
        self.tactical = tactical
        self.physical = physical
        self.mental = mental
    }
}
