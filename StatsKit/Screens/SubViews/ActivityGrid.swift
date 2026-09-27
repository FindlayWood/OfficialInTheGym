//
//  ActivityGrid.swift
//  StatsKit
//
//  Created by Findlay Wood on 13/08/2026.
//

import SwiftUI

// MARK: - ActivityGrid
/// The last four weeks of training, laid out like a calendar: **a column per
/// weekday, a row per week**, oldest week at the top.
///
/// This replaced a single row of thirty dots — thirty circles across a card is
/// about 7½pt each, and a dot could only ever say trained / did not.
///
/// **Weekdays run horizontally because that is how a calendar reads.** The first
/// version of this grid ran the other way (a column per week, seven weekday
/// rows) to fit twelve weeks in. It is the denser layout, but it asks the eye to
/// read down-then-across against every calendar the user has ever seen. Four
/// weeks across seven columns is the familiar shape, and at seven columns the
/// cells are large enough to carry a legible intensity.
///
/// **Columns are pinned Monday-first rather than deferring to
/// `StatsDay.calendar.firstWeekday`,** which is locale-driven — leaving it to the
/// calendar would shift every cell by device region while the day keys
/// underneath stayed exactly where they were.
struct ActivityGrid: View {
    let totals: [DailyTotal]

    private let weeks = 4
    private let columnCount = 7
    private let spacing: CGFloat = 6
    private let cellHeight: CGFloat = 34

    /// Sets per day key. **Intensity, not presence** — the dot strip drew a day
    /// with one set and a day with twenty in the same green.
    private var setsByKey: [String: Int] {
        Dictionary(totals.map { ($0.id, $0.totalSets) }, uniquingKeysWith: +)
    }

    /// Today's column, Monday = 0. `.weekday` is 1 = Sunday … 7 = Saturday.
    private var todayColumn: Int {
        let weekday = StatsDay.calendar.component(.weekday, from: .now)
        return (weekday + 5) % 7
    }

    var body: some View {
        VStack(alignment: .trailing, spacing: 8) {
            weekdayHeader

            VStack(spacing: spacing) {
                ForEach(0..<weeks, id: \.self) { row in
                    HStack(spacing: spacing) {
                        ForEach(0..<columnCount, id: \.self) { column in
                            cell(row: row, column: column)
                        }
                    }
                }
            }

            legend
        }
    }

    // MARK: - Cells

    @ViewBuilder
    private func cell(row: Int, column: Int) -> some View {
        if let daysAgo = daysAgo(row: row, column: column) {
            let sets = setsByKey[StatsDay.key(daysAgo: daysAgo)] ?? 0
            RoundedRectangle(cornerRadius: 8)
                .fill(fill(forSets: sets))
                .frame(maxWidth: .infinity)
                .frame(height: cellHeight)
        } else {
            // The current week is the bottom row and is partly in the future. A
            // day that has not happened is left blank rather than drawn empty —
            // it has not had the chance to be a rest day yet, and shading it as
            // one misreports the week in progress.
            Color.clear
                .frame(maxWidth: .infinity)
                .frame(height: cellHeight)
        }
    }

    /// How many days before today this cell is, or `nil` if it is in the future.
    private func daysAgo(row: Int, column: Int) -> Int? {
        let value = (weeks - 1 - row) * 7 + (todayColumn - column)
        return value >= 0 ? value : nil
    }

    /// **Fixed thresholds, deliberately not scaled to the user's own maximum.**
    /// A relative scale repaints history every time a heavier week lands, so the
    /// same session shows a different colour depending on what happened after
    /// it — which makes the grid unreadable as a record of what you did.
    private func fill(forSets sets: Int) -> Color {
        switch sets {
        case 0:       return Color(.tertiarySystemFill)
        case 1...5:   return .darkColor.opacity(0.28)
        case 6...12:  return .darkColor.opacity(0.52)
        case 13...20: return .darkColor.opacity(0.76)
        default:      return .darkColor
        }
    }

    // MARK: - Chrome

    private var weekdayHeader: some View {
        HStack(spacing: spacing) {
            ForEach(0..<columnCount, id: \.self) { column in
                Text(Self.weekdayInitials[column])
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(column == todayColumn ? Color.darkColor : .secondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private static let weekdayInitials = ["M", "T", "W", "T", "F", "S", "S"]

    private var legend: some View {
        HStack(spacing: 4) {
            Text("Less")
            ForEach([0, 3, 9, 16, 24], id: \.self) { sets in
                RoundedRectangle(cornerRadius: 2)
                    .fill(fill(forSets: sets))
                    .frame(width: 9, height: 9)
            }
            Text("More")
        }
        .font(.system(size: 9))
        .foregroundStyle(.secondary)
    }
}

// MARK: - Preview
#Preview {
    ActivityGrid(totals: MockDailyTotalsProvider().previewTotals)
        .padding()
        .background(Color(.systemBackground))
}
