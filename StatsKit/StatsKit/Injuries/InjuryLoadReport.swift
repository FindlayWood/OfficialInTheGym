//
//  InjuryLoadReport.swift
//  StatsKit
//
//  Created by Findlay Wood on 10/11/2026.
//

import Foundation

/// Training around one injury: the load before it started, and how training changed while it
/// lasted. See `READINESS_PLAN.md` part 3.
///
/// **It states facts, never causes.** A spike before an injury is worth seeing; saying it caused
/// the injury is a claim the data cannot support, and the page says so in words.
///
/// **Every ratio is `ACWR.rolling`**, the module's one calculation, run on the same two load
/// series as everywhere else (`TrainingLoadMetric`), kept separate for the same reasons.
///
/// **A number is only given when the data under it was fetched.** STATS is handed
/// `StatsHistoryWindow.days` of totals. The peak in the four weeks before an injury needs a
/// chronic window behind each of those days — 56 days before the start in all — and a ratio
/// computed over days that were never fetched reads too high, which on this page would invent
/// a spike. So `before` is `nil` for an injury that started too long ago, and the page says why.
struct InjuryLoadReport {

    static let lookbackDays = 28
    static let acuteDays = 7

    struct MetricBefore: Equatable {
        let metric: TrainingLoadMetric
        /// The ratio on the day it started.
        let atStart: ACWR
        /// The highest ratio in the `lookbackDays` before it started, and how many days before.
        let peak: (ratio: Double, daysBefore: Int)?
        /// The week before the start against the week before that, as a fraction (+0.38 = 38% more).
        /// `nil` when the earlier week had no load, where a percentage means nothing.
        let weekOnWeekChange: Double?

        static func == (lhs: MetricBefore, rhs: MetricBefore) -> Bool {
            lhs.metric == rhs.metric && lhs.atStart.ratio == rhs.atStart.ratio
                && lhs.peak?.ratio == rhs.peak?.ratio && lhs.peak?.daysBefore == rhs.peak?.daysBefore
                && lhs.weekOnWeekChange == rhs.weekOnWeekChange
        }
    }

    struct Rates: Equatable {
        let daysTrainedPerWeek: Double
        let setsPerWeek: Double
        let volumePerWeek: Double
    }

    struct During: Equatable {
        let days: Int
        /// While it lasted, per week.
        let rates: Rates
        /// The four weeks before it started, per week. `nil` when those weeks were not fetched.
        let ratesBefore: Rates?
        /// Muscle group ids by share of volume while it lasted, largest first, at most three.
        let topMuscleGroups: [(id: String, share: Double)]

        static func == (lhs: During, rhs: During) -> Bool {
            lhs.days == rhs.days && lhs.rates == rhs.rates && lhs.ratesBefore == rhs.ratesBefore
                && lhs.topMuscleGroups.map(\.id) == rhs.topMuscleGroups.map(\.id)
        }
    }

    /// Both metrics, session first. `nil` when the weeks before were not fetched.
    let before: [MetricBefore]?
    /// `nil` for an injury under a week old — a per-week rate from two days is a guess.
    let during: During?

    init(
        injury: StatsInjury,
        totals: [DailyTotal],
        today: Date = .now,
        historyDays: Int = StatsHistoryWindow.days
    ) {
        guard let start = injury.startDate else {
            before = nil
            during = nil
            return
        }
        let startDaysAgo = StatsDay.calendar.dateComponents([.day], from: start, to: StatsDay.startOfDay(for: today)).day ?? 0
        let byKey = Dictionary(totals.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })

        // The peak's oldest point needs its own chronic window behind it.
        if startDaysAgo + Self.lookbackDays + 28 <= historyDays {
            before = TrainingLoadMetric.allCases.map { metric in
                Self.before(metric: metric, start: start, loads: totals.loadByDay(metric))
            }
        } else {
            before = nil
        }

        let duringKeys = injury.dayKeys(today: today)
        if duringKeys.count >= 7 {
            let beforeKeys = (1...Self.lookbackDays).reversed().map { StatsDay.key(daysAgo: $0, from: start) }
            let ratesBefore = startDaysAgo + Self.lookbackDays <= historyDays
                ? Self.rates(over: beforeKeys, in: byKey)
                : nil
            during = During(
                days: duringKeys.count,
                rates: Self.rates(over: duringKeys, in: byKey),
                ratesBefore: ratesBefore,
                topMuscleGroups: Self.topMuscleGroups(over: duringKeys, in: byKey)
            )
        } else {
            during = nil
        }
    }

    private static func before(metric: TrainingLoadMetric, start: Date, loads: [String: Double]) -> MetricBefore {
        let atStart = ACWR.rolling(loadByDay: loads, endingOn: start)

        var peak: (ratio: Double, daysBefore: Int)?
        for daysBefore in 1...lookbackDays {
            let day = StatsDay.date(daysAgo: daysBefore, from: start)
            guard let ratio = ACWR.rolling(loadByDay: loads, endingOn: day).ratio else { continue }
            if ratio > (peak?.ratio ?? -.infinity) {
                peak = (ratio, daysBefore)
            }
        }

        func weekLoad(endingDaysBefore offset: Int) -> Double {
            (offset..<(offset + acuteDays)).reduce(0) { sum, daysBefore in
                sum + (loads[StatsDay.key(daysAgo: daysBefore, from: start)] ?? 0)
            }
        }
        let lastWeek = weekLoad(endingDaysBefore: 1)
        let weekBefore = weekLoad(endingDaysBefore: 1 + acuteDays)
        let change = weekBefore > 0 ? (lastWeek - weekBefore) / weekBefore : nil

        return MetricBefore(metric: metric, atStart: atStart, peak: peak, weekOnWeekChange: change)
    }

    /// Per week over `keys`, rest days counting as zero — the ACWR's rule, so a fortnight with
    /// one session reads as one session a fortnight, not one a week.
    private static func rates(over keys: [String], in byKey: [String: DailyTotal]) -> Rates {
        let weeks = Double(keys.count) / 7
        let days = keys.compactMap { byKey[$0] }
        return Rates(
            daysTrainedPerWeek: Double(days.count) / weeks,
            setsPerWeek: Double(days.reduce(0) { $0 + $1.totalSets }) / weeks,
            volumePerWeek: days.reduce(0) { $0 + $1.totalVolume } / weeks
        )
    }

    private static func topMuscleGroups(over keys: [String], in byKey: [String: DailyTotal]) -> [(id: String, share: Double)] {
        var volumes: [String: Double] = [:]
        for total in keys.compactMap({ byKey[$0] }) {
            volumes.merge(total.muscleGroupVolumes, uniquingKeysWith: +)
        }
        let sum = volumes.values.reduce(0, +)
        guard sum > 0 else { return [] }
        return volumes
            .sorted { $0.value != $1.value ? $0.value > $1.value : $0.key < $1.key }
            .prefix(3)
            .map { ($0.key, $0.value / sum) }
    }
}
