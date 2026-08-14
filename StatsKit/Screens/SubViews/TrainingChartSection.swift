//
//  TrainingChartSection.swift
//  StatsKit
//
//  Created by Findlay Wood on 13/08/2026.
//

import SwiftUI

// MARK: - TrainingChartSection
/// The home screen's lead card: twelve weeks of training as bars, with the
/// current week called out above them.
///
/// **This is the only thing on the tab with a shape rather than a number, and it
/// is first for that reason.** Everything else here is a rectangle of digits;
/// nothing was drawing the eye, and the numbers that did exist were the ones a
/// user has to already care about to read. A chart says "you have been training,
/// here is the run of it" before anything has to be interpreted.
///
/// **Weekly buckets, not daily.** At a realistic training frequency a 30-bar
/// daily chart is mostly gaps and reads as noise. Weekly totals show progression,
/// which is the thing worth coming back to look at.
///
/// **Bars, not a line.** A week's total is a discrete sum and a rest week is
/// genuinely zero; a line would draw a slope between two weeks that implies
/// values in between which were never measured. The ACWR detail screen uses a
/// line correctly — a rolling ratio really is continuous.
struct TrainingChartSection: View {
    let totals: [DailyTotal]

    @State private var metric: TrainingChartMetric = .volume

    private var weeks: [TrainingWeek] { TrainingWeek.buckets(from: totals) }

    var body: some View {
        SectionContainer(title: "Training · last 12 weeks") {
            VStack(alignment: .leading, spacing: 16) {
                metricPicker

                if weeks.allSatisfy(\.isEmpty) {
                    emptyState
                } else {
                    headline
                    TrainingWeekBars(weeks: weeks, metric: metric)
                    axisLabels
                }
            }
            .padding(16)
        }
    }

    // MARK: - Metric picker

    private var metricPicker: some View {
        HStack(spacing: 6) {
            ForEach(TrainingChartMetric.allCases) { option in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) { metric = option }
                } label: {
                    MetricPickerLabel(title: option.title, isSelected: option == metric)
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Headline

    private var headline: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text(metric.formatted(currentValue))
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(Color.darkColor)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .contentTransition(.numericText())

            VStack(alignment: .leading, spacing: 2) {
                if let unit = metric.unitLabel {
                    Text(unit)
                        .font(.subheadline).fontWeight(.medium)
                        .foregroundStyle(.secondary)
                }
                Text("last 7 days")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if let change = weekOnWeekChange {
                changeChip(change)
            }
        }
    }

    /// The newest bucket — the same seven days the figures under the chart cover.
    private var currentValue: Double {
        weeks.last.map { metric.value(from: $0) } ?? 0
    }

    /// Change against the week before, as a fraction.
    ///
    /// `nil` when the previous week was empty: everything is an infinite increase
    /// on zero, and "↑ ∞%" after a week off is noise rather than information.
    private var weekOnWeekChange: Double? {
        guard weeks.count >= 2 else { return nil }
        let previous = metric.value(from: weeks[weeks.count - 2])
        guard previous > 0 else { return nil }
        return (currentValue - previous) / previous
    }

    /// **Deliberately not colour-coded up-good / down-bad.** More load is not
    /// better — the ACWR card two rows down exists to say that a spike is a
    /// risk, and a deload week showing a red arrow would contradict it. The chip
    /// reports the direction and leaves the judgement to the ratio.
    private func changeChip(_ change: Double) -> some View {
        HStack(spacing: 3) {
            Image(systemName: change >= 0 ? "arrow.up.right" : "arrow.down.right")
                .font(.system(size: 10, weight: .bold))
            Text(String(format: "%.0f%%", abs(change) * 100))
                .font(.caption).fontWeight(.semibold)
        }
        .foregroundStyle(.secondary)
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(Color(.tertiarySystemFill))
        .clipShape(Capsule())
    }

    // MARK: - Axis

    private var axisLabels: some View {
        HStack {
            Text(Self.axisFormatter.string(from: weeks.first?.start ?? .now))
            Spacer()
            Text("This week")
        }
        .font(.system(size: 10))
        .foregroundStyle(.secondary)
    }

    /// Formatted in the user's locale for display, from a date looked up through
    /// `StatsDay` — the split the module requires.
    private static let axisFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        return formatter
    }()

    // MARK: - Empty state

    private var emptyState: some View {
        VStack(spacing: 6) {
            Image(systemName: "chart.bar")
                .font(.system(size: 26, weight: .light))
                .foregroundStyle(.tertiary)
            Text("No training logged yet")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text("Your last 12 weeks will show here")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
    }
}

// MARK: - MetricPickerLabel
/// One segment of the metric toggle.
///
/// Its own view because the selected/unselected ternaries inline in the button
/// label pushed the section body past the type-checker's budget. The selected
/// fill is `Color.darkColor` — this is a selection, and every selected control
/// in the app is the brand colour, whatever the series it switches to is drawn in.
private struct MetricPickerLabel: View {
    let title: String
    let isSelected: Bool

    private var fill: Color { isSelected ? .darkColor : Color(.tertiarySystemFill) }
    private var tint: Color { isSelected ? .white : .secondary }

    var body: some View {
        Text(title)
            .font(.caption).fontWeight(.semibold)
            .lineLimit(1)
            .minimumScaleFactor(0.8)
            .foregroundStyle(tint)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 7)
            .background(fill)
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - TrainingWeekBars
/// The bars themselves.
///
/// **One colour — `Color.darkColor` — with opacity carrying magnitude**, the
/// same ramp `ActivityGrid` uses, so the two cards read as one system rather
/// than four metric palettes that changed under a toggle. A bigger week is a
/// darker bar as well as a taller one.
///
/// The newest bar used to be drawn at full strength and the rest at 45% to tie
/// the headline to the chart. **That emphasis is gone deliberately**: now that
/// opacity means magnitude, spending it on recency too would make a big old week
/// and the current week indistinguishable. The axis labels the newest bar
/// "This week" instead.
///
/// An empty week keeps a 3pt stub in `tertiarySystemFill` rather than
/// disappearing, so a week off is visibly a week that happened with nothing in it.
private struct TrainingWeekBars: View {
    let weeks: [TrainingWeek]
    let metric: TrainingChartMetric

    private var maxValue: Double {
        weeks.map { metric.value(from: $0) }.max() ?? 0
    }

    var body: some View {
        GeometryReader { geo in
            let spacing: CGFloat = 5
            let barWidth = (geo.size.width - spacing * CGFloat(weeks.count - 1))
                / CGFloat(weeks.count)

            HStack(alignment: .bottom, spacing: spacing) {
                ForEach(weeks) { week in
                    let value = metric.value(from: week)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(fill(for: value))
                        .frame(width: barWidth, height: height(for: value, in: geo.size.height))
                }
            }
            .frame(width: geo.size.width, height: geo.size.height, alignment: .bottom)
        }
        .frame(height: 120)
        .animation(.easeInOut(duration: 0.25), value: metric)
    }

    /// Floored at 0.30 so the quietest trained week is still legibly a bar and
    /// not a smudge — the height already separates it from the weeks above.
    private func fill(for value: Double) -> Color {
        guard maxValue > 0, value > 0 else { return Color(.tertiarySystemFill) }
        return .darkColor.opacity(0.30 + 0.70 * (value / maxValue))
    }

    private func height(for value: Double, in available: CGFloat) -> CGFloat {
        guard maxValue > 0, value > 0 else { return 3 }
        return max(3, CGFloat(value / maxValue) * available)
    }
}

// MARK: - Preview
#Preview {
    ScrollView {
        TrainingChartSection(totals: MockDailyTotalsProvider().previewTotals)
            .padding()
    }
    .background(Color.darkColor.ignoresSafeArea())
}

#Preview("Empty") {
    ScrollView {
        TrainingChartSection(totals: [])
            .padding()
    }
    .background(Color.darkColor.ignoresSafeArea())
}
