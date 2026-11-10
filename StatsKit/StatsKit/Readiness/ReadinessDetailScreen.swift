//
//  ReadinessDetailScreen.swift
//  StatsKit
//
//  Created by Findlay Wood on 10/11/2026.
//

import SwiftUI

/// Readiness over four or twelve weeks, or any one of the four questions behind it, with
/// injuries shaded; the average of each question over the range; and the day RPEs.
///
/// **Which question is pulling readiness down is the point of the averages card.** Readiness
/// alone says a week was rough; sleep at 2.1 beside body at 3.8 says why.
struct ReadinessDetailScreen: View {

    let days: [ReadinessDay]
    let injuries: [StatsInjury]

    @State private var metric: ReadinessMetric = .readiness
    @State private var range: ReadinessRange = .fourWeeks

    var body: some View {
        let keys = ReadinessSeries.dayKeys(length: range.days)
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Picker("Range", selection: $range) {
                    ForEach(ReadinessRange.allCases) { range in
                        Text(range.label).tag(range)
                    }
                }
                .pickerStyle(.segmented)

                chartSection(keys: keys)
                averagesSection(keys: keys)
                rpeSection(keys: keys)

                Text("Readiness is your four check-in answers together: sleep, body, focus and mood. The line is a seven-day average of the days you checked in; days you didn't are left out, not counted as zero.")
                    .font(.footnote)
                    .foregroundStyle(Color.white.opacity(0.75))
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 2)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .background { Color.pageColor.ignoresSafeArea() }
        .navigationTitle("Readiness")
        .navigationBarTitleDisplayMode(.large)
    }

    // MARK: - Chart

    private func chartSection(keys: [String]) -> some View {
        let series = ReadinessSeries(days: days, metric: metric, dayKeys: keys)
        let mean = ReadinessSeries.mean(of: metric, in: days, over: keys)
        return SectionContainer(title: metric.title) {
            VStack(alignment: .leading, spacing: 14) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(ReadinessMetric.allCases) { candidate in
                            Button { metric = candidate } label: {
                                Text(candidate.title)
                                    .font(.system(size: 13, weight: .semibold))
                                    .padding(.horizontal, 12)
                                    .frame(height: 30)
                                    .background(
                                        Capsule().fill(candidate == metric ? Color.darkColor : Color(.tertiarySystemGroupedBackground))
                                    )
                                    .foregroundStyle(candidate == metric ? Color.white : Color.secondary)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text(mean.map(metric.formatted) ?? "—")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                    Text("average over \(range.label.lowercased())")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                ReadinessChart(series: series, injuryBands: InjuryChartBands.bands(for: injuries, over: keys))

                if !injuries.isEmpty {
                    HStack(spacing: 6) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.matteRed.opacity(0.18))
                            .frame(width: 14, height: 8)
                        Text("Injured")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(16)
        }
    }

    // MARK: - Averages

    private func averagesSection(keys: [String]) -> some View {
        SectionContainer(title: "Averages") {
            VStack(spacing: 12) {
                ForEach(ReadinessMetric.allCases.filter { $0 != .readiness }) { question in
                    let mean = ReadinessSeries.mean(of: question, in: days, over: keys)
                    HStack(spacing: 12) {
                        Text(question.title)
                            .font(.subheadline)
                            .frame(width: 56, alignment: .leading)
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule().fill(Color(.tertiarySystemGroupedBackground))
                                Capsule()
                                    .fill(Color.darkColor)
                                    .frame(width: geo.size.width * CGFloat(mean ?? 0))
                            }
                        }
                        .frame(height: 8)
                        Text(mean.map(question.formatted) ?? "—")
                            .font(.subheadline.weight(.semibold))
                            .frame(width: 64, alignment: .trailing)
                    }
                }
            }
            .padding(16)
        }
    }

    // MARK: - Day RPE

    /// How hard each rated day felt, 1–10. A day not rated draws no bar.
    private func rpeSection(keys: [String]) -> some View {
        let byKey = Dictionary(days.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        let rated = keys.compactMap { byKey[$0]?.dayRPE }
        return SectionContainer(title: "Day RPE") {
            VStack(alignment: .leading, spacing: 8) {
                if rated.isEmpty {
                    Text("No days rated in this range.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else {
                    Text("Average \(String(format: "%.1f", Double(rated.reduce(0, +)) / Double(rated.count))) over \(rated.count) rated \(rated.count == 1 ? "day" : "days")")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    GeometryReader { geo in
                        let slot = geo.size.width / CGFloat(max(keys.count, 1))
                        HStack(alignment: .bottom, spacing: 0) {
                            ForEach(keys, id: \.self) { key in
                                VStack {
                                    Spacer(minLength: 0)
                                    if let rpe = byKey[key]?.dayRPE {
                                        RoundedRectangle(cornerRadius: 2)
                                            .fill(Color.matteAmber)
                                            .frame(width: max(2, slot * 0.6), height: geo.size.height * CGFloat(rpe) / 10)
                                    }
                                }
                                .frame(width: slot)
                            }
                        }
                    }
                    .frame(height: 70)
                }
            }
            .padding(16)
        }
    }
}

// MARK: - ReadinessRange
enum ReadinessRange: String, CaseIterable, Identifiable {
    case fourWeeks = "4W"
    case twelveWeeks = "12W"

    var id: String { rawValue }

    var label: String {
        switch self {
        case .fourWeeks: return "4 weeks"
        case .twelveWeeks: return "12 weeks"
        }
    }

    var days: Int {
        switch self {
        case .fourWeeks: return 28
        case .twelveWeeks: return 84
        }
    }
}

#Preview {
    NavigationStack {
        ReadinessDetailScreen(days: MockReadinessProvider.samples, injuries: PreviewInjuryHistoryLoader.samples)
    }
}
