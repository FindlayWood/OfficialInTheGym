//
//  StatsThisWeekCard.swift
//  StatsKit
//
//  Created by Findlay Wood on 27/10/2026.
//

import SwiftUI

/// The free view's lead card: Monday to Sunday as seven cells, then the week in words.
///
/// **The cells are `ActivityGrid`'s newest row, drawn the same way** — same Monday-first columns,
/// same fixed set thresholds (`ActivityGrid.fill(forSets:)`), today's initial in `darkColor`. A
/// subscriber sees this row grow into the four-week grid, so the two must shade a day alike.
///
/// **An empty week says "Nothing logged yet", never "Rest".** Nothing logged is not the same as
/// rested — the rule MyDay's timeline follows.
struct StatsThisWeekCard: View {
    let summary: StatsFreeSummary

    private let spacing: CGFloat = 6
    private let cellHeight: CGFloat = 34

    private var totals: DailyTotalSummary { summary.thisWeekTotals }

    var body: some View {
        SectionContainer(title: "This week") {
            VStack(alignment: .leading, spacing: 16) {
                week
                Divider()
                figures
            }
            .padding(16)
        }
    }

    // MARK: - Week

    private var week: some View {
        VStack(spacing: 8) {
            HStack(spacing: spacing) {
                ForEach(summary.thisWeek) { day in
                    Text(ActivityGrid.weekdayInitials[day.id])
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(day.id == summary.todayColumn ? Color.darkColor : .secondary)
                        .frame(maxWidth: .infinity)
                }
            }

            HStack(spacing: spacing) {
                ForEach(summary.thisWeek) { day in
                    if let sets = day.sets {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(ActivityGrid.fill(forSets: sets))
                            .frame(maxWidth: .infinity)
                            .frame(height: cellHeight)
                    } else {
                        // A day still to come is blank, not empty — see `StatsFreeSummary.thisWeek`.
                        Color.clear
                            .frame(maxWidth: .infinity)
                            .frame(height: cellHeight)
                    }
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityWeek)
    }

    // MARK: - Figures

    @ViewBuilder
    private var figures: some View {
        VStack(alignment: .leading, spacing: 4) {
            if totals.activeDays == 0 {
                Text("Nothing logged yet this week")
                    .font(.system(size: 17, weight: .semibold))
                Text("Log a set in MyDay and it shows up here.")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
            } else {
                Text(totals.activeDays == 1 ? "1 day trained" : "\(totals.activeDays) days trained")
                    .font(.system(size: 17, weight: .semibold))
                Text(measures)
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
            }

            Text(lastWeek)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.secondary)
                .padding(.top, 4)
        }
    }

    /// Sets, plus time only when there is some — "0m" on a lifting week reads as a fault.
    private var measures: String {
        var parts = [totals.totalSets == 1 ? "1 set" : "\(totals.totalSets) sets"]
        if totals.totalTime > 0 { parts.append(totals.formattedTime) }
        return parts.joined(separator: " · ")
    }

    private var lastWeek: String {
        let days = summary.daysTrainedLastWeek
        return "Last week: \(days == 1 ? "1 day" : "\(days) days")"
    }

    private var accessibilityWeek: String {
        let names = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
        let trained = summary.thisWeek
            .filter { ($0.sets ?? 0) > 0 }
            .map { names[$0.id] }
        return trained.isEmpty
            ? "No days trained this week"
            : "Trained this week on \(trained.joined(separator: ", "))"
    }
}

#Preview {
    StatsThisWeekCard(summary: StatsFreeSummary(totals: MockDailyTotalsProvider().previewTotals))
        .padding()
        .background(Color.pageColor)
}
