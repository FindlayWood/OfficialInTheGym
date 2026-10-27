//
//  StatsFreeSummary.swift
//  StatsKit
//
//  Created by Findlay Wood on 27/10/2026.
//

import Foundation

// MARK: - StatsFreeSummary
/// What the STATS tab shows without pro: this week, last week's count, the streak, and which
/// exercises to try for the top lift.
///
/// **Free users see their own week, not a blurred sample of someone else's.** The locked screen
/// used to be the only thing on the tab without pro, so the people who never paid never saw the
/// one thing that would have made them: their own numbers. The persona reviews asked for exactly
/// this — "did I go twice this week?" — and the welcome screen's "See it add up" promised it.
/// The twelve-week chart, the four-week grid, both ratios and training balance stay pro.
///
/// **"This week" is Monday to Sunday, not the last seven days.** The card names the days, so it
/// has to mean the calendar week the words describe. (`TrainingWeek` rolls instead, so the
/// chart's newest bar does not collapse every Monday — that reason does not apply to a card that
/// says "this week".) The week starts on `StatsDay.weekdayColumn`, the same Monday
/// `ActivityGrid` uses.
///
/// **Every day key comes from `StatsDay`, never `Calendar.current`.** A consequence worth
/// knowing: for a user far from UTC, a late-evening session is filed under the next UTC day and
/// lands in the next cell, so this card and MyDay's `MyDayWeekCard` (device calendar) can
/// disagree by a day. That is the trade the rest of STATS already makes.
struct StatsFreeSummary {

    let totals: [DailyTotal]

    /// What "now" means. Injectable so tests can pin the weekday.
    var asOf: Date = .now

    /// The window the top lift is judged over, and the window before it is compared with.
    static let topLiftWindowDays = 28

    // MARK: - This week

    /// Today's column, Monday = 0.
    var todayColumn: Int {
        StatsDay.weekdayColumn(for: asOf)
    }

    /// Monday to Sunday. A day still to come has `sets == nil` — it has not had the chance to be
    /// trained or not, and drawing it empty would misreport the week in progress.
    var thisWeek: [StatsWeekDay] {
        let setsByKey = self.setsByKey
        return (0..<7).map { column in
            let daysAgo = todayColumn - column
            guard daysAgo >= 0 else { return StatsWeekDay(id: column, sets: nil) }
            return StatsWeekDay(id: column, sets: setsByKey[StatsDay.key(daysAgo: daysAgo, from: asOf)] ?? 0)
        }
    }

    /// This week's totals summed — sets, time, active days.
    var thisWeekTotals: DailyTotalSummary {
        DailyTotalSummary.from(totals(daysAgo: 0...todayColumn))
    }

    /// Days trained in the whole of last week, Monday to Sunday.
    var daysTrainedLastWeek: Int {
        totals(daysAgo: (todayColumn + 1)...(todayColumn + 7)).count
    }

    // MARK: - Streak

    /// **The home's streak, not a second one** — today is allowed to be pending there too.
    var streak: Int {
        HomeStats(totals: totals, asOf: asOf).streak
    }

    // MARK: - Top lift

    /// Exercise ids by sets logged in the last four weeks, most first — ties broken by id so the
    /// order never shuffles between loads. `DailyTotal` cannot say which exercises carried
    /// weight, so these are *candidates*: `StatsTopLift` decides from each one's daily stats.
    var topLiftCandidates: [String] {
        totals(daysAgo: 0...(Self.topLiftWindowDays - 1))
            .exerciseSetCounts
            .filter { $0.value > 0 }
            .sorted { $0.value != $1.value ? $0.value > $1.value : $0.key < $1.key }
            .map(\.key)
    }

    // MARK: - Helpers

    private var setsByKey: [String: Int] {
        Dictionary(totals.map { ($0.id, $0.totalSets) }, uniquingKeysWith: +)
    }

    private func totals(daysAgo range: ClosedRange<Int>) -> [DailyTotal] {
        let keys = Set(range.map { StatsDay.key(daysAgo: $0, from: asOf) })
        return totals.filter { keys.contains($0.id) }
    }
}

// MARK: - StatsWeekDay
/// One cell of the free "This week" card. `sets` is `nil` for a day still to come.
struct StatsWeekDay: Identifiable, Equatable {
    /// Monday = 0 … Sunday = 6.
    let id: Int
    let sets: Int?
}
