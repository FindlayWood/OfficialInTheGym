//
//  ReadinessSummaryView.swift
//  StatsKit
//
//  Created by Findlay Wood on 10/11/2026.
//

import SwiftUI

/// The home's readiness card: this week's average, the change on last week, and four weeks of
/// the chart. Taps through to `ReadinessDetailScreen`.
///
/// **The change is in points and not colour-coded**, as the training chart's chip is not: a
/// lower readiness in a heavy block is expected, and a red arrow would read as a failure.
///
/// Not drawn until there is a check-in to show — logging lives on MyDay.
struct ReadinessSummaryView: View {

    let days: [ReadinessDay]
    let injuries: [StatsInjury]
    let onDetail: () -> Void

    private var thisWeek: [String] { ReadinessSeries.dayKeys(length: 7) }
    private var lastWeek: [String] {
        (7..<14).reversed().map { StatsDay.key(daysAgo: $0) }
    }

    var body: some View {
        let keys = ReadinessSeries.dayKeys(length: 28)
        let current = ReadinessSeries.mean(of: .readiness, in: days, over: thisWeek)
        let previous = ReadinessSeries.mean(of: .readiness, in: days, over: lastWeek)
        SectionContainer(title: "Readiness") {
            Button(action: onDetail) {
                VStack(alignment: .leading, spacing: 14) {
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text(current.map(ReadinessMetric.readiness.formatted) ?? "—")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.primary)
                        if let current, let previous {
                            changeChip(points: Int(((current - previous) * 100).rounded()))
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                    Text(subtitle(current: current))
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    ReadinessChart(
                        series: ReadinessSeries(days: days, metric: .readiness, dayKeys: keys),
                        injuryBands: InjuryChartBands.bands(for: injuries, over: keys),
                        height: 70,
                        showsLabels: false
                    )
                }
                .padding(16)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
    }

    private func subtitle(current: Double?) -> String {
        let count = days.filter { Set(thisWeek).contains($0.id) && $0.readiness != nil }.count
        guard current != nil else { return "No check-ins in the last 7 days" }
        return "Last 7 days · \(count) check-\(count == 1 ? "in" : "ins")"
    }

    private func changeChip(points: Int) -> some View {
        Text(points == 0 ? "Same as last week" : "\(points > 0 ? "+" : "")\(points) pts on last week")
            .font(.caption2.weight(.semibold))
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .background(Color(.tertiarySystemGroupedBackground))
            .foregroundStyle(.secondary)
            .clipShape(Capsule())
    }
}
