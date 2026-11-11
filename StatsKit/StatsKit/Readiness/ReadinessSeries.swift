//
//  ReadinessSeries.swift
//  StatsKit
//
//  Created by Findlay Wood on 10/11/2026.
//

import Foundation

/// One metric over a run of days: each day's value and the seven-day average.
///
/// **A day with no check-in is a gap, never a zero.** Unlike load, where a rest day really is
/// zero, a missed check-in says nothing about how the user felt; counting it as zero would make
/// a busy week look like a terrible one.
///
/// **The average needs at least `minimumForAverage` check-ins in its seven days**, so one
/// answer after a week away is not drawn as a week's trend.
struct ReadinessSeries {

    static let window = 7
    static let minimumForAverage = 3

    let dayKeys: [String]
    let values: [Double?]
    let average: [Double?]

    init(days: [ReadinessDay], metric: ReadinessMetric, dayKeys: [String]) {
        let byKey = Dictionary(days.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        self.dayKeys = dayKeys
        values = dayKeys.map { byKey[$0].flatMap(metric.value(from:)) }
        average = dayKeys.map { key in
            guard let end = DateFormatter.yyyyMMdd.date(from: key) else { return nil }
            let recent = (0..<Self.window).compactMap { offset in
                byKey[StatsDay.key(daysAgo: offset, from: end)].flatMap(metric.value(from:))
            }
            guard recent.count >= Self.minimumForAverage else { return nil }
            return recent.reduce(0, +) / Double(recent.count)
        }
    }

    /// The last `length` days ending today, oldest first.
    static func dayKeys(length: Int, endingOn today: Date = .now) -> [String] {
        (0..<length).reversed().map { StatsDay.key(daysAgo: $0, from: today) }
    }

    /// The mean of the check-ins in `keys`, or `nil` with none.
    static func mean(of metric: ReadinessMetric, in days: [ReadinessDay], over keys: [String]) -> Double? {
        let wanted = Set(keys)
        let values = days.filter { wanted.contains($0.id) }.compactMap(metric.value(from:))
        guard !values.isEmpty else { return nil }
        return values.reduce(0, +) / Double(values.count)
    }
}
