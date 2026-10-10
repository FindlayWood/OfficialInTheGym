//
//  WorkloadRatio.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import Foundation

/// The legacy workload metrics over the Realtime Database workload log: acute
/// and chronic load, their ratio, monotony, training strain and freshness.
///
/// **This is not StatsKit's `ACWR`, and must not be merged with it.** It reads a
/// different log (`Workload`, not MyDay's `DailyTotal`s), buckets days with the
/// device calendar rather than UTC keys, and is what every match and practice
/// record already stores. It was written out twice, in the match and practice
/// trackers, and a third time in the Workload tool. This is the one copy.
///
/// Kept exactly as it was, defects included, so new records agree with old ones:
/// - **Monotony uses the legacy `stdev()`, which is wrong.** It computes
///   `sqrt(Σ(x − mean)² / n − 1)`, where the standard deviation is
///   `sqrt(Σ(x − mean)² / (n − 1))`. It is often the square root of a negative
///   number, so `monotony` and `trainingStrain` are often NaN, stored as 0.
///   Fixing it belongs to the redesign, with a decision about the records
///   already written.
/// - Any NaN is stored as 0. With no chronic load, `acwr` is 0, not "no data".
public struct WorkloadRatio: Equatable, Sendable {
    public let acwr: Double
    public let monotony: Double
    public let trainingStrain: Double
    public let acuteLoad: Double
    public let chronicLoad: Double
    public let freshnessIndex: Double

    public init(acwr: Double, monotony: Double, trainingStrain: Double, acuteLoad: Double, chronicLoad: Double, freshnessIndex: Double) {
        self.acwr = acwr
        self.monotony = monotony
        self.trainingStrain = trainingStrain
        self.acuteLoad = acuteLoad
        self.chronicLoad = chronicLoad
        self.freshnessIndex = freshnessIndex
    }

    /// The metrics as of `daysBack` days ago: a 7-day acute window and a 28-day
    /// chronic window, each ending that day. `daysAgo` buckets a workload by
    /// how many calendar days before today it ended.
    static func calculate(from workloads: [Workload], daysBack: Int = 0, daysAgo: (Date) -> Int) -> WorkloadRatio {
        let acute = dailyTotals(workloads, from: daysBack, length: 7, daysAgo: daysAgo)
        let chronic = dailyTotals(workloads, from: daysBack, length: 28, daysAgo: daysAgo)
        let acuteLoad = acute.reduce(0, +)
        let chronicLoad = chronic.reduce(0, +) / 4
        let acwr = acuteLoad / chronicLoad
        let mean = acuteLoad / Double(acute.count)
        let monotony = mean / legacyStandardDeviation(of: acute)
        let trainingStrain = acuteLoad * monotony
        let freshnessIndex = chronicLoad - acuteLoad
        return WorkloadRatio(
            acwr: acwr.isNaN ? 0 : acwr,
            monotony: monotony.isNaN ? 0 : monotony,
            trainingStrain: trainingStrain.isNaN ? 0 : trainingStrain,
            acuteLoad: acuteLoad.isNaN ? 0 : acuteLoad,
            chronicLoad: chronicLoad.isNaN ? 0 : chronicLoad,
            freshnessIndex: freshnessIndex.isNaN ? 0 : freshnessIndex
        )
    }

    /// How many calendar days before `now` a workload ended, in the device's
    /// calendar: the legacy `TimeInterval.daysAgo()`. A workload at 23:59
    /// yesterday is one day ago, as is one at 00:01.
    static func daysAgo(_ date: Date, now: Date, calendar: Calendar = .current) -> Int {
        let from = calendar.startOfDay(for: date)
        let to = calendar.startOfDay(for: now)
        return calendar.dateComponents([.day], from: from, to: to).day ?? 0
    }

    /// One total per day, `length` days starting `from` days ago, newest first.
    private static func dailyTotals(_ workloads: [Workload], from start: Int, length: Int, daysAgo: (Date) -> Int) -> [Double] {
        var totals = (0..<length).map { _ in 0.0 }
        for workload in workloads {
            let day = daysAgo(workload.endTime)
            guard day >= start && day < start + length else { continue }
            totals[day - start] += workload.total
        }
        return totals
    }

    /// The app target's `Array.stdev()`, defect and all. See the type's comment.
    private static func legacyStandardDeviation(of values: [Double]) -> Double {
        let mean = values.reduce(0, +) / Double(values.count)
        let squares = values.reduce(0) { $0 + ($1 - mean) * ($1 - mean) }
        return sqrt(squares / Double(values.count) - 1)
    }
}
