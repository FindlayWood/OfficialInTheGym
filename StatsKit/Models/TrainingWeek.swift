//
//  TrainingWeek.swift
//  StatsKit
//
//  Created by Findlay Wood on 13/08/2026.
//

import Foundation

// MARK: - TrainingWeek
/// One seven-day bucket of `DailyTotal`s — a single bar on the home chart.
///
/// **Buckets are built through `StatsDay`, never `Calendar.current`.** A bucket
/// is a span of day *keys* looked up against `DailyTotal.id`, which is a UTC
/// document id minted server-side. Stepping the span in the device calendar puts
/// its boundary a day out from the data it is collecting for every user east of
/// GMT, so each bar silently borrows a day from its neighbour — the same defect
/// `StatsDay` exists to prevent on the streak and the ACWR windows.
public struct TrainingWeek: Identifiable, Sendable {

    /// Position in the series, oldest first. Doubles as the x-axis index.
    public let id: Int

    /// The first day the bucket covers. Held for labelling only — format it in
    /// the user's locale at the point of display, never to look data up.
    public let start: Date

    public let sets: Int
    public let reps: Int
    public let volume: Double
    public let time: Int

    public init(id: Int, start: Date, sets: Int, reps: Int, volume: Double, time: Int) {
        self.id = id
        self.start = start
        self.sets = sets
        self.reps = reps
        self.volume = volume
        self.time = time
    }

    public var isEmpty: Bool {
        sets == 0 && reps == 0 && volume == 0 && time == 0
    }
}

// MARK: - Bucketing
public extension TrainingWeek {

    /// `weeks` buckets of seven days each, oldest first, the newest ending today.
    ///
    /// **The newest bucket is days 0–6 — a rolling seven days, not a calendar
    /// week.** The figures beside the chart read "last 7 days" and have to cover
    /// the same span as the bar above them. Bucketing by calendar week instead
    /// would make the newest bar a partial one that collapses to nothing every
    /// Monday and refills over the following week, which reads as training
    /// falling off a cliff rather than a week that has not happened yet.
    ///
    /// A day with no document contributes nothing rather than being skipped, so
    /// a week off is a genuinely empty bar instead of a gap in the series.
    static func buckets(
        from totals: [DailyTotal],
        weeks: Int = 12,
        endingOn day: Date = .now
    ) -> [TrainingWeek] {
        // `uniquingKeysWith` rather than `Dictionary(uniqueKeysWithValues:)`,
        // which traps on a duplicate key. Ids are Firestore document ids and so
        // are unique today, but a crash is a bad way to learn that changed.
        let totalsByKey = Dictionary(
            totals.map { ($0.id, $0) },
            uniquingKeysWith: { first, _ in first }
        )

        return (0..<weeks).map { index in
            let newestOffset = (weeks - 1 - index) * 7
            let bucket = (0..<7).compactMap {
                totalsByKey[StatsDay.key(daysAgo: newestOffset + $0, from: day)]
            }

            return TrainingWeek(
                id: index,
                start: StatsDay.date(daysAgo: newestOffset + 6, from: day),
                sets: bucket.reduce(0) { $0 + $1.totalSets },
                reps: bucket.reduce(0) { $0 + $1.totalReps },
                volume: bucket.reduce(0) { $0 + $1.totalVolume },
                time: bucket.reduce(0) { $0 + $1.totalTime }
            )
        }
    }
}
