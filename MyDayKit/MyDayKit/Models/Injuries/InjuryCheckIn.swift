//
//  InjuryCheckIn.swift
//  MyDayKit
//
//  Created by Findlay Wood on 10/11/2026.
//

import Foundation

/// How one injury felt on one day: pain from 0 to 10 and how much it changed training.
///
/// **Kept on the injury, keyed by day** (`Injury.checkIns`), so there is one per injury per day
/// and a second save that day corrects it. Each carries its own `updatedAt` because check-ins
/// from two devices are merged one day at a time (`Injury.merged`) — the injury's own
/// `updatedAt` cannot say which copy of a single day is newer.
public struct InjuryCheckIn: Codable, Hashable, Sendable {
    public static let painRange = 0...10

    public let pain: Int
    public let impact: InjuryImpact
    public let updatedAt: Date

    public init(pain: Int, impact: InjuryImpact, updatedAt: Date) {
        self.pain = min(max(pain, Self.painRange.lowerBound), Self.painRange.upperBound)
        self.impact = impact
        self.updatedAt = updatedAt
    }

    var summary: String {
        "Pain \(pain) · \(impact.summary)"
    }
}
