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
    public let exerciseSetCounts: [String: Int]           // Changed from exerciseSetsCount
    public let muscleGroupVolumes: [String: Double]       // NEW
    public let movementTypeVolumes: [String: Double]      // NEW

    public init(
        id: String,
        date: Date,
        userID: String,
        totalSets: Int,
        totalReps: Int,
        totalWeight: Double,
        totalVolume: Double,
        totalTime: Int,
        exerciseSetCounts: [String: Int],
        muscleGroupVolumes: [String: Double] = [:],
        movementTypeVolumes: [String: Double] = [:]
    ) {
        self.id = id
        self.date = date
        self.userID = userID
        self.totalSets = totalSets
        self.totalReps = totalReps
        self.totalWeight = totalWeight
        self.totalVolume = totalVolume
        self.totalTime = totalTime
        self.exerciseSetCounts = exerciseSetCounts
        self.muscleGroupVolumes = muscleGroupVolumes
        self.movementTypeVolumes = movementTypeVolumes
    }
    
    // Custom decoding to handle missing fields gracefully
    enum CodingKeys: String, CodingKey {
        case id, date, userID
        case totalSets, totalReps, totalWeight, totalVolume, totalTime
        case exerciseSetCounts
        case muscleGroupVolumes
        case movementTypeVolumes
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        date = try container.decode(Date.self, forKey: .date)
        userID = try container.decode(String.self, forKey: .userID)
        totalSets = try container.decode(Int.self, forKey: .totalSets)
        totalReps = try container.decode(Int.self, forKey: .totalReps)
        totalWeight = try container.decode(Double.self, forKey: .totalWeight)
        totalVolume = try container.decode(Double.self, forKey: .totalVolume)
        totalTime = try container.decode(Int.self, forKey: .totalTime)
        exerciseSetCounts = try container.decodeIfPresent([String: Int].self, forKey: .exerciseSetCounts) ?? [:]
        muscleGroupVolumes = try container.decodeIfPresent([String: Double].self, forKey: .muscleGroupVolumes) ?? [:]
        movementTypeVolumes = try container.decodeIfPresent([String: Double].self, forKey: .movementTypeVolumes) ?? [:]
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
    public let exerciseSetCounts: [String: Int]
    public let muscleGroupVolumes: [String: Double]
    public let movementTypeVolumes: [String: Double]

    public static let empty = DailyTotalSummary(
        totalSets: 0, totalReps: 0, totalWeight: 0,
        totalVolume: 0, totalTime: 0, activeDays: 0,
        exerciseSetCounts: [:],
        muscleGroupVolumes: [:],
        movementTypeVolumes: [:]
    )

    public init(
        totalSets: Int,
        totalReps: Int,
        totalWeight: Double,
        totalVolume: Double,
        totalTime: Int,
        activeDays: Int,
        exerciseSetCounts: [String: Int],
        muscleGroupVolumes: [String: Double] = [:],
        movementTypeVolumes: [String: Double] = [:]
    ) {
        self.totalSets = totalSets
        self.totalReps = totalReps
        self.totalWeight = totalWeight
        self.totalVolume = totalVolume
        self.totalTime = totalTime
        self.activeDays = activeDays
        self.exerciseSetCounts = exerciseSetCounts
        self.muscleGroupVolumes = muscleGroupVolumes
        self.movementTypeVolumes = movementTypeVolumes
    }

    public static func from(_ totals: [DailyTotal]) -> DailyTotalSummary {
        // Merge all exercise set counts
        var mergedExerciseSetCounts: [String: Int] = [:]
        for total in totals {
            for (exerciseID, count) in total.exerciseSetCounts {
                mergedExerciseSetCounts[exerciseID, default: 0] += count
            }
        }
        
        // Merge all muscle group volumes
        var mergedMuscleGroupVolumes: [String: Double] = [:]
        for total in totals {
            for (muscleGroup, volume) in total.muscleGroupVolumes {
                mergedMuscleGroupVolumes[muscleGroup, default: 0] += volume
            }
        }
        
        // Merge all movement type volumes
        var mergedMovementTypeVolumes: [String: Double] = [:]
        for total in totals {
            for (movementType, volume) in total.movementTypeVolumes {
                mergedMovementTypeVolumes[movementType, default: 0] += volume
            }
        }
        
        return DailyTotalSummary(
            totalSets: totals.reduce(0) { $0 + $1.totalSets },
            totalReps: totals.reduce(0) { $0 + $1.totalReps },
            totalWeight: totals.reduce(0) { $0 + $1.totalWeight },
            totalVolume: totals.reduce(0) { $0 + $1.totalVolume },
            totalTime: totals.reduce(0) { $0 + $1.totalTime },
            activeDays: totals.count,
            exerciseSetCounts: mergedExerciseSetCounts,
            muscleGroupVolumes: mergedMuscleGroupVolumes,
            movementTypeVolumes: mergedMovementTypeVolumes
        )
    }

    public var formattedVolume: String {
        totalVolume >= 1000
            ? String(format: "%.1fk", totalVolume / 1000)
            : String(format: "%.0f", totalVolume)
    }

    public var formattedTime: String {
        let h = totalTime / 3600
        let m = (totalTime % 3600) / 60
        if h > 0 { return "\(h)h \(m)m" }
        return "\(m)m"
    }
    
    /// Top muscle groups by volume
    public var topMuscleGroups: [(muscleGroup: String, volume: Double)] {
        muscleGroupVolumes
            .sorted { $0.value > $1.value }
            .map { ($0.key, $0.value) }
    }
    
    /// Top movement types by volume
    public var topMovementTypes: [(movementType: String, volume: Double)] {
        movementTypeVolumes
            .sorted { $0.value > $1.value }
            .map { ($0.key, $0.value) }
    }
    
    /// Get volume for a specific muscle group
    public func volumeFor(muscleGroup: String) -> Double {
        muscleGroupVolumes[muscleGroup] ?? 0
    }
    
    /// Get volume for a specific movement type
    public func volumeFor(movementType: String) -> Double {
        movementTypeVolumes[movementType] ?? 0
    }
}

// MARK: - Array Extension for exerciseSetCounts merging
extension Array where Element == DailyTotal {
    /// Merges all exerciseSetCounts from multiple DailyTotal objects
    public var exerciseSetCounts: [String: Int] {
        var merged: [String: Int] = [:]
        for total in self {
            for (exerciseID, count) in total.exerciseSetCounts {
                merged[exerciseID, default: 0] += count
            }
        }
        return merged
    }
    
    /// Merges all muscleGroupVolumes from multiple DailyTotal objects
    public var muscleGroupVolumes: [String: Double] {
        var merged: [String: Double] = [:]
        for total in self {
            for (muscleGroup, volume) in total.muscleGroupVolumes {
                merged[muscleGroup, default: 0] += volume
            }
        }
        return merged
    }
    
    /// Merges all movementTypeVolumes from multiple DailyTotal objects
    public var movementTypeVolumes: [String: Double] {
        var merged: [String: Double] = [:]
        for total in self {
            for (movementType, volume) in total.movementTypeVolumes {
                merged[movementType, default: 0] += volume
            }
        }
        return merged
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
