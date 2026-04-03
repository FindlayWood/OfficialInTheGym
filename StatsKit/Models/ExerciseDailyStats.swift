//
//  ExerciseDailyStats.swift
//  StatsKit
//
//  Created by Findlay Wood on 22/03/2026.
//

import Foundation

// MARK: - ExerciseDailyStats
// Matches the document written to
// Users/{userID}/ExerciseStats/{exerciseID}/DailyStats/{yyyy-MM-dd}
// by the dailyExerciseStatsFromRawLog Cloud Functions.
public struct ExerciseDailyStats: Identifiable, Hashable, Sendable, Decodable {
    public let id: String
    public let date: Date
    public let exerciseID: String
    public let exerciseName: String?
    public let userID: String
    public let totalSets: Int
    public let totalReps: Int
    public let totalWeight: Double
    public let totalVolume: Double
    public let totalTime: Int
    public let maxWeight: Double?
    public let maxTime: Int?
 
    public init(
        id: String,
        date: Date,
        exerciseID: String,
        exerciseName: String?,
        userID: String,
        totalSets: Int,
        totalReps: Int,
        totalWeight: Double,
        totalVolume: Double,
        totalTime: Int,
        maxWeight: Double,
        maxTime: Int
    ) {
        self.id = id
        self.date = date
        self.exerciseID = exerciseID
        self.exerciseName = exerciseName
        self.userID = userID
        self.totalSets = totalSets
        self.totalReps = totalReps
        self.totalWeight = totalWeight
        self.totalVolume = totalVolume
        self.totalTime = totalTime
        self.maxWeight = maxWeight
        self.maxTime = maxTime
    }
}

struct WeeklyStat {
    let week: Date
    let volume: Double
}
 
// MARK: - DetailRange
// Separate from HomeRange — covers longer periods needed for exercise detail.
public enum DetailRange: String, CaseIterable, Identifiable, Sendable {
    case week     = "1W"
    case twoWeeks = "2W"
    case month    = "1M"
    case threeMonths = "3M"
 
    public var id: String { rawValue }
 
    public var days: Int {
        switch self {
        case .week:         return 7
        case .twoWeeks:     return 14
        case .month:        return 30
        case .threeMonths:  return 90
        }
    }
 
    public var cutoffDate: Date {
        Calendar.current.date(byAdding: .day, value: -days, to: .now)!
    }
}

// MARK: - PeriodStats
// Aggregated stats for one rolling window, derived client-side from dailyStats.
public struct PeriodStats {
    public let range: DetailRange
    public let activeDays: Int
 
    public let totalReps: Int
    public let avgRepsPerDay: Double
 
    public let maxWeight: Double
    public let avgMaxWeight: Double
 
    public let totalVolume: Double
    public let avgVolumePerDay: Double
 
    public let totalTime: Int
    public let avgTimePerDay: Double
 
    // MARK: Formatted strings
 
    public var formattedTotalReps: String   { "\(totalReps)" }
    public var formattedAvgReps: String     {
        activeDays > 0 ? String(format: "%.1f avg/day", avgRepsPerDay) : "—"
    }
 
    public var formattedMaxWeight: String   {
        maxWeight > 0 ? "\(Int(maxWeight))kg" : "—"
    }
    public var formattedAvgWeight: String   {
        avgMaxWeight > 0 ? String(format: "%.1fkg avg/day", avgMaxWeight) : "—"
    }
 
    public var formattedTotalVolume: String {
        totalVolume > 0
            ? (totalVolume >= 1000
                ? String(format: "%.1fk", totalVolume / 1000)
                : "\(Int(totalVolume))")
            : "—"
    }
    public var formattedAvgVolume: String {
        guard activeDays > 0 && totalVolume > 0 else { return "—" }
        let avg = avgVolumePerDay
        return avg >= 1000
            ? String(format: "%.1fk avg/day", avg / 1000)
            : String(format: "%.0f avg/day", avg)
    }
 
    public var formattedTotalTime: String   { totalTime > 0 ? Self.formatTime(totalTime) : "—" }
    public var formattedAvgTime: String     {
        guard activeDays > 0 && totalTime > 0 else { return "—" }
        return "\(Self.formatTime(Int(avgTimePerDay))) avg/day"
    }
 
    static func compute(from stats: [ExerciseDailyStats], range: DetailRange) -> PeriodStats {
        let filtered = stats.filter { $0.date >= range.cutoffDate }
        let count = filtered.count
 
        let totalReps = filtered.reduce(0) { $0 + $1.totalReps }
        let maxWeight = filtered.compactMap(\.maxWeight).max() ?? 0
        let avgMaxWeight = count > 0
        ? filtered.compactMap(\.maxWeight).reduce(0, +) / Double(range.days)
            : 0
        let totalVolume = filtered.reduce(0) { $0 + $1.totalVolume }
        let totalTime = filtered.reduce(0) { $0 + $1.totalTime }
 
        return PeriodStats(
            range: range,
            activeDays: count,
            totalReps: totalReps,
            avgRepsPerDay: count > 0 ? Double(totalReps) / Double(range.days) : 0,
            maxWeight: maxWeight,
            avgMaxWeight: avgMaxWeight,
            totalVolume: totalVolume,
            avgVolumePerDay: count > 0 ? totalVolume / Double(range.days) : 0,
            totalTime: totalTime,
            avgTimePerDay: count > 0 ? Double(totalTime) / Double(range.days) : 0
        )
    }
 
    static func formatTime(_ secs: Int) -> String {
        let h = secs / 3600
        let m = (secs % 3600) / 60
        let s = secs % 60
        return h > 0
            ? String(format: "%d:%02d:%02d", h, m, s)
            : String(format: "%d:%02d", m, s)
    }
}
 
// MARK: - DetailMetric
// The metric shown in the chart picker
public enum DetailMetric: String, CaseIterable, Identifiable, Sendable {
    case reps   = "Reps"
    case weight = "Weight"
    case volume = "Volume"
    case time   = "Time"
 
    public var id: String { rawValue }
}
 
// MARK: - MetricACWR
// Per-metric ACWR using standard 7-day acute / 28-day chronic windows.
// nil means no data (chronic window is 0 — not enough history).
public struct MetricACWR {
    public let reps: Double?
    public let weight: Double?
    public let volume: Double?
    public let time: Double?
 
    static func compute(from stats: [ExerciseDailyStats]) -> MetricACWR {
        let acute = stats.filter { $0.date >= acuteCutoff }
        let chronic = stats.filter { $0.date >= chronicCutoff }
 
        func ratio<T: BinaryInteger>(
            acuteVal: T,
            chronicDays: [ExerciseDailyStats],
            chronicTotal: (ExerciseDailyStats) -> T
        ) -> Double? {
            let chronicSum = chronicDays.reduce(0) { $0 + chronicTotal($1) }
            // Chronic = average daily load over 28 days (including rest days)
            let chronicAvgPerDay = Double(chronicSum) / 28.0
            guard chronicAvgPerDay > 0 else { return nil }
            // Acute = average daily load over 7 days
            let acuteAvgPerDay = Double(acuteVal) / 7.0
            return acuteAvgPerDay / chronicAvgPerDay
        }
 
        func ratioDouble(
            acuteVal: Double,
            chronicDays: [ExerciseDailyStats],
            chronicTotal: (ExerciseDailyStats) -> Double
        ) -> Double? {
            let chronicSum = chronicDays.reduce(0.0) { $0 + chronicTotal($1) }
            let chronicAvgPerDay = chronicSum / 28.0
            guard chronicAvgPerDay > 0 else { return nil }
            let acuteAvgPerDay = acuteVal / 7.0
            return acuteAvgPerDay / chronicAvgPerDay
        }
 
        return MetricACWR(
            reps: ratio(
                acuteVal: acute.reduce(0) { $0 + $1.totalReps },
                chronicDays: chronic,
                chronicTotal: { $0.totalReps }
            ),
            weight: ratioDouble(
                acuteVal: acute.compactMap(\.maxWeight).max() ?? 0,
                chronicDays: chronic,
                chronicTotal: { $0.maxWeight ?? 0 }
            ),
            volume: ratioDouble(
                acuteVal: acute.reduce(0) { $0 + $1.totalVolume },
                chronicDays: chronic,
                chronicTotal: { $0.totalVolume }
            ),
            time: ratio(
                acuteVal: acute.reduce(0) { $0 + $1.totalTime },
                chronicDays: chronic,
                chronicTotal: { $0.totalTime }
            )
        )
    }
 
    private static var acuteCutoff: Date {
        Calendar.current.date(byAdding: .day, value: -7, to: .now)!
    }
    private static var chronicCutoff: Date {
        Calendar.current.date(byAdding: .day, value: -28, to: .now)!
    }
}

// MARK: - ACWRZone
public enum ACWRZone: Sendable {
    case optimal, caution, danger, low, insufficient
 
    public static func zone(for ratio: Double?) -> ACWRZone {
        guard let r = ratio else { return .insufficient }
        switch r {
        case ..<0.8:    return .low
        case 0.8..<1.3: return .optimal
        case 1.3..<1.5: return .caution
        default:        return .danger
        }
    }
 
    public var label: String {
        switch self {
        case .optimal:      return "Optimal"
        case .caution:      return "Caution"
        case .danger:       return "High risk"
        case .low:          return "Low load"
        case .insufficient: return "No data"
        }
    }
}
 
// MARK: - ExerciseDailyStatsProviding
public protocol ExerciseDailyStatsProviding {
    func fetchDailyStats(
        exerciseID: String,
        from: Date
    ) async throws -> [ExerciseDailyStats]
}
 
// MARK: - Mock implementation
public final class MockExerciseDailyStatsProvider: ExerciseDailyStatsProviding, @unchecked Sendable {
    private let stats: [ExerciseDailyStats]
 
    public init(stats: [ExerciseDailyStats]? = nil) {
        self.stats = stats ?? MockExerciseDailyStatsProvider.generated()
    }
 
    public func fetchDailyStats(exerciseID: String, from: Date) async throws -> [ExerciseDailyStats] {
        stats.filter { $0.date >= from }.sorted { $0.date < $1.date }
    }
 
    public var previewStats: [ExerciseDailyStats] { stats }
 
    // Generates 90 days of mock data spread realistically
    private static func generated() -> [ExerciseDailyStats] {
        let activeDayOffsets = [0, 2, 3, 5, 7, 9, 11, 14, 16, 18,
                                21, 23, 25, 28, 30, 32, 35, 37, 40,
                                42, 44, 47, 49, 51, 54, 56, 58, 62,
                                65, 67, 70, 72, 75, 77, 80, 84, 88]
        return activeDayOffsets.map { offset in
            let date = Calendar.current.date(byAdding: .day, value: -offset, to: .now)!
            let key = DateFormatter.yyyyMMdd.string(from: date)
            let reps = Int.random(in: 8...25)
            let weight = Double(Int.random(in: 40...130))
            return ExerciseDailyStats(
                id: key,
                date: date,
                exerciseID: "mockExercise",
                exerciseName: "Mock Exercise",
                userID: "mockUser",
                totalSets: Int.random(in: 2...5),
                totalReps: reps,
                totalWeight: weight,
                totalVolume: Double(reps) * weight,
                totalTime: Int.random(in: 30...300),
                maxWeight: weight,
                maxTime: Int.random(in: 30...300)
            )
        }
    }
}

