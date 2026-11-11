//
//  InjuryDetailScreen.swift
//  StatsKit
//
//  Created by Findlay Wood on 10/11/2026.
//

import SwiftUI

/// One injury's page: how it felt, the load around it, what the weeks before looked like, and
/// how training changed while it lasted. Pushed from the home's Injuries card, so pro.
///
/// **Facts, never causes** — see `InjuryLoadReport`. The page ends by saying so, and that it is
/// not medical advice, because a ratio beside an injury is exactly where people read one in.
///
/// Everything is worked out from what the home already holds (`totals`), so the page fetches
/// nothing, as a route carrying its inputs promises.
struct InjuryDetailScreen: View {

    let injury: StatsInjury
    let totals: [DailyTotal]
    let muscleGroups: [MuscleGroup]
    var readiness: [ReadinessDay] = []

    @State private var metric: TrainingLoadMetric = .session

    private var report: InjuryLoadReport {
        InjuryLoadReport(injury: injury, totals: totals)
    }

    var body: some View {
        let report = report
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header

                SectionContainer(title: "Pain") {
                    if injury.checkIns.isEmpty {
                        emptyText("Not rated yet. Rate it in your MyDay check-in.")
                    } else {
                        InjuryPainChart(injury: injury)
                    }
                }

                if let before = report.before {
                    loadAround
                    beforeSection(before)
                } else {
                    SectionContainer(title: "Before it started") {
                        emptyText("This started before the \(StatsHistoryWindow.days / 7) weeks of training STATS reads, so the weeks before it can't be shown.")
                    }
                }

                duringSection(report.during)

                Text("These are facts about your training around this injury, not its cause, and not medical advice. If it's not improving, see a physio or doctor.")
                    .font(.footnote)
                    .foregroundStyle(Color.white.opacity(0.75))
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 2)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .background { Color.pageColor.ignoresSafeArea() }
        .navigationTitle(injury.title)
        .navigationBarTitleDisplayMode(.large)
    }

    // MARK: - Header

    private var header: some View {
        SectionContainer {
            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(InjuryDayFormat.span(of: injury))
                        .font(.system(size: 15, weight: .semibold))
                    if let latest = injury.latestCheckIn {
                        Text("Last rated: pain \(latest.pain), \(latest.impact.title.lowercased())")
                            .font(.system(size: 13))
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
                Text(injury.isCurrent ? "Current" : "Cleared")
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 9)
                    .padding(.vertical, 4)
                    .background((injury.isCurrent ? Color.matteRed : Color.matteGreen).opacity(0.14))
                    .foregroundStyle(injury.isCurrent ? Color.matteRed : Color.matteGreen)
                    .clipShape(Capsule())
            }
            .padding(16)
        }
    }

    // MARK: - Load around it

    /// The ratio from four weeks before the start to its last day, with the injury shaded, so a
    /// spike before it sits beside it.
    private var loadAround: some View {
        let start = injury.startDate ?? .now
        let end = injury.lastDay() ?? .now
        let span = (StatsDay.calendar.dateComponents([.day], from: start, to: end).day ?? 0) + InjuryLoadReport.lookbackDays
        let days = (0...span).reversed().map { StatsDay.date(daysAgo: $0, from: end) }
        let loads = totals.loadByDay(metric)
        let keys = days.map(StatsDay.key(for:))
        let readinessSeries = ReadinessSeries(days: readiness, metric: .readiness, dayKeys: keys)
        return VStack(alignment: .leading, spacing: 10) {
            Picker("Metric", selection: $metric) {
                ForEach(TrainingLoadMetric.allCases) { metric in
                    Text(metric.title).tag(metric)
                }
            }
            .pickerStyle(.segmented)

            ACWRProgressionChart(
                title: "Load around it",
                values: days.map { ACWR.rolling(loadByDay: loads, endingOn: $0).ratio },
                labels: keys.map(InjuryDayFormat.short),
                injuryBands: InjuryChartBands.bands(for: [injury], over: keys)
            )

            if readinessSeries.values.contains(where: { $0 != nil }) {
                SectionContainer(title: "Readiness around it") {
                    ReadinessChart(
                        series: readinessSeries,
                        injuryBands: InjuryChartBands.bands(for: [injury], over: keys)
                    )
                    .padding(16)
                }
            }
        }
    }

    // MARK: - Before

    private func beforeSection(_ before: [InjuryLoadReport.MetricBefore]) -> some View {
        SectionContainer(title: "Before it started") {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(before.enumerated()), id: \.offset) { index, item in
                    beforeRows(item)
                    if index < before.count - 1 { Divider() }
                }
            }
        }
    }

    private func beforeRows(_ item: InjuryLoadReport.MetricBefore) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(item.metric.title)
                    .font(.subheadline.weight(.semibold))
                Text(item.metric.subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            factRow("On the day it started", value: item.atStart.formattedRatio, detail: item.atStart.zone.label, color: item.atStart.zone.color)
            if let peak = item.peak {
                let zone = ACWR.Zone(ratio: peak.ratio)
                factRow(
                    "Highest in the 4 weeks before",
                    value: String(format: "%.2f", peak.ratio),
                    detail: "\(peak.daysBefore) \(peak.daysBefore == 1 ? "day" : "days") before",
                    color: zone.color
                )
            } else {
                factRow("Highest in the 4 weeks before", value: "—", detail: "No load logged", color: .secondary)
            }
            factRow("Week before vs the week before that", value: changeText(item.weekOnWeekChange), detail: nil, color: .primary)
        }
        .padding(16)
    }

    // MARK: - During

    private func duringSection(_ during: InjuryLoadReport.During?) -> some View {
        SectionContainer(title: injury.isCurrent ? "Since it started" : "While it lasted") {
            if let during {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Spacer()
                        Text("Now").frame(width: 70, alignment: .trailing)
                        Text("Before").frame(width: 70, alignment: .trailing)
                    }
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

                    compareRow("Days trained / week", during.rates.daysTrainedPerWeek, during.ratesBefore?.daysTrainedPerWeek, decimals: 1)
                    compareRow("Sets / week", during.rates.setsPerWeek, during.ratesBefore?.setsPerWeek, decimals: 0)
                    compareRow("Volume / week", during.rates.volumePerWeek, during.ratesBefore?.volumePerWeek, decimals: 0)

                    if !during.topMuscleGroups.isEmpty {
                        Divider()
                        Text("Most trained")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                        ForEach(during.topMuscleGroups, id: \.id) { group in
                            HStack {
                                Text(muscleGroupName(group.id))
                                    .font(.subheadline)
                                Spacer()
                                Text("\(Int((group.share * 100).rounded()))%")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(Color.darkColor)
                            }
                        }
                    }

                    if during.ratesBefore == nil {
                        Text("\u{201C}Before\u{201D} is the four weeks before it started, which is further back than STATS reads.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(16)
            } else {
                emptyText("Too early to compare. Check back once it's a week old.")
            }
        }
    }

    // MARK: - Pieces

    private func factRow(_ label: String, value: String, detail: String?, color: Color) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer(minLength: 8)
            Text(value)
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundStyle(color)
            if let detail {
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func compareRow(_ label: String, _ now: Double, _ before: Double?, decimals: Int) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
            Spacer()
            Text(format(now, decimals: decimals))
                .font(.subheadline.weight(.semibold))
                .frame(width: 70, alignment: .trailing)
            Text(before.map { format($0, decimals: decimals) } ?? "—")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(width: 70, alignment: .trailing)
        }
    }

    private func emptyText(_ text: String) -> some View {
        Text(text)
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    /// Not colour-coded up-good / down-bad, as the home's change chip is not: more load is not
    /// better, and a drop before an injury is as worth seeing as a rise.
    private func changeText(_ change: Double?) -> String {
        guard let change else { return "—" }
        let percent = Int((change * 100).rounded())
        return percent > 0 ? "+\(percent)%" : "\(percent)%"
    }

    private func format(_ value: Double, decimals: Int) -> String {
        if decimals == 0 && value >= 1000 {
            return String(format: "%.1fk", value / 1000)
        }
        return String(format: "%.\(decimals)f", value)
    }

    private func muscleGroupName(_ id: String) -> String {
        muscleGroups.first { $0.id == id }?.name ?? id
    }
}

#Preview {
    NavigationStack {
        InjuryDetailScreen(
            injury: PreviewInjuryHistoryLoader.samples[1],
            totals: MockDailyTotalsProvider().previewTotals,
            muscleGroups: []
        )
    }
}
