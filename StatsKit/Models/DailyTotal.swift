//
//  DailyTotal.swift
//  StatsKit
//
//  Created by Findlay Wood on 21/03/2026.
//

import Foundation

// MARK: - DailyTotal
// Matches the document written to Users/{userID}/DailyTotals/{yyyy-MM-dd}
// by the dailyStatsFromRawLog Cloud Functions.
public struct DailyTotal: Identifiable, Hashable, Sendable, Decodable {
    public let id: String           // yyyy-MM-dd date key, also the Firestore document ID
    public let date: Date
    public let userID: String
    public let totalSets: Int
    public let totalReps: Int
    public let totalWeight: Double
    public let totalVolume: Double
    public let totalTime: Int       // seconds
    public let exercisesWorked: [String]

    public init(
        id: String,
        date: Date,
        userID: String,
        totalSets: Int,
        totalReps: Int,
        totalWeight: Double,
        totalVolume: Double,
        totalTime: Int,
        exercisesWorked: [String]
    ) {
        self.id = id
        self.date = date
        self.userID = userID
        self.totalSets = totalSets
        self.totalReps = totalReps
        self.totalWeight = totalWeight
        self.totalVolume = totalVolume
        self.totalTime = totalTime
        self.exercisesWorked = exercisesWorked
    }
}

// MARK: - DailyTotalSummary
// Aggregated totals across a range of DailyTotal documents.
public struct DailyTotalSummary: Sendable {
    public let totalSets: Int
    public let totalReps: Int
    public let totalWeight: Double
    public let totalVolume: Double
    public let totalTime: Int
    public let activeDays: Int
    public let exercisesWorked: [String]

    public static let empty = DailyTotalSummary(
        totalSets: 0, totalReps: 0, totalWeight: 0,
        totalVolume: 0, totalTime: 0, activeDays: 0,
        exercisesWorked: []
    )

    public init(
        totalSets: Int,
        totalReps: Int,
        totalWeight: Double,
        totalVolume: Double,
        totalTime: Int,
        activeDays: Int,
        exercisesWorked: [String]
    ) {
        self.totalSets = totalSets
        self.totalReps = totalReps
        self.totalWeight = totalWeight
        self.totalVolume = totalVolume
        self.totalTime = totalTime
        self.activeDays = activeDays
        self.exercisesWorked = exercisesWorked
    }

    public static func from(_ totals: [DailyTotal]) -> DailyTotalSummary {
        let exerciseIDs = Array(Set(totals.flatMap(\.exercisesWorked))).sorted()
        return DailyTotalSummary(
            totalSets: totals.reduce(0) { $0 + $1.totalSets },
            totalReps: totals.reduce(0) { $0 + $1.totalReps },
            totalWeight: totals.reduce(0) { $0 + $1.totalWeight },
            totalVolume: totals.reduce(0) { $0 + $1.totalVolume },
            totalTime: totals.reduce(0) { $0 + $1.totalTime },
            activeDays: totals.count,
            exercisesWorked: exerciseIDs
        )
    }

    public var formattedVolume: String {
        totalVolume >= 1000
            ? String(format: "%.1fk", totalVolume / 1000)
            : String(Int(totalVolume))
    }

    public var formattedTime: String {
        let h = totalTime / 3600
        let m = (totalTime % 3600) / 60
        if h > 0 { return "\(h)h \(m)m" }
        return "\(m)m"
    }
}

// MARK: - HomeRange
public enum HomeRange: String, CaseIterable, Identifiable, Sendable {
    case week     = "1W"
    case twoWeeks = "2W"
    case month    = "1M"

    public var id: String { rawValue }

    public var days: Int {
        switch self {
        case .week:     return 7
        case .twoWeeks: return 14
        case .month:    return 30
        }
    }

    public var cutoffDate: Date {
        Calendar.current.date(byAdding: .day, value: -days, to: .now)!
    }

    /// yyyy-MM-dd string for the cutoff — passed to the provider for Firestore queries
    public var cutoffDateKey: String {
        DateFormatter.yyyyMMdd.string(from: cutoffDate)
    }
}

// MARK: - Shared DateFormatter
extension DateFormatter {
    static let yyyyMMdd: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.timeZone = TimeZone(identifier: "UTC")
        return f
    }()
}
