//
//  ProgressChartSection.swift
//  StatsKit
//
//  Created by Findlay Wood on 27/03/2026.
//

import SwiftUI

// MARK: - WeeklyChartData
// One bucket per 7-day rolling window. Always 13 buckets = 91 days.
struct WeeklyChartData: Identifiable {
    let id: Int
    let label: String
    let volume: Double
    let maxWeight: Double
    let totalReps: Int
    let totalTime: Int
    var hasData: Bool { volume > 0 || maxWeight > 0 || totalReps > 0 || totalTime > 0 }
}

// MARK: - ACWRPoint
// Rolling ACWR: acute = that week's total, chronic = avg of prior 3 weeks.
// Always 13 entries — first 3 have nil values (used only as chronic baseline).
struct ACWRPoint: Identifiable {
    let id: Int
    let label: String
    let reps: Double?
    let weight: Double?
    let volume: Double?
    let time: Double?

    var hasAnyValue: Bool {
        reps != nil || weight != nil || volume != nil || time != nil
    }
}

// MARK: - Shared week builder
// Produces 13 WeeklyChartData buckets from dailyStats.
// Shared by both chart sections so x-axis is identical.
private func buildWeeks(
    from dailyStats: [ExerciseDailyStats]
) -> [WeeklyChartData] {
    let labelFmt = DateFormatter()
    labelFmt.dateFormat = "d MMM"
    let statsByKey = Dictionary(grouping: dailyStats, by: \.id)

    return (0..<13).map { weekIndex in
        let daysAgoEnd   = (12 - weekIndex) * 7
        let daysAgoStart = daysAgoEnd + 6
        let bucketDates  = (daysAgoEnd...daysAgoStart).compactMap {
            Calendar.current.date(byAdding: .day, value: -$0, to: .now)
        }
        let bucketStats = bucketDates
            .compactMap { statsByKey[DateFormatter.yyyyMMdd.string(from: $0)] }
            .flatMap { $0 }
        let weekStart = bucketDates.last ?? .now

        return WeeklyChartData(
            id: weekIndex,
            label: labelFmt.string(from: weekStart),
            volume:    bucketStats.reduce(0.0) { $0 + $1.totalVolume },
            maxWeight: bucketStats.compactMap(\.maxWeight).max() ?? 0,
            totalReps: bucketStats.reduce(0) { $0 + $1.totalReps },
            totalTime: bucketStats.reduce(0) { $0 + $1.totalTime }
        )
    }
}

// MARK: - ACWR zone colour
private func acwrColor(_ ratio: Double) -> Color {
    switch ratio {
    case ..<0.8:    return .blue
    case 0.8..<1.3: return .green
    case 1.3..<1.5: return .orange
    default:        return .red
    }
}

// MARK: - ProgressChartsSection
struct ProgressChartsSection: View {
    let dailyStats: [ExerciseDailyStats]
    let exercise: ExerciseStats

    private var weeks: [WeeklyChartData] { buildWeeks(from: dailyStats) }
    private var showVolume: Bool { exercise.maxWeight > 0 || exercise.totalVolume > 0 }
    private var showWeight: Bool { exercise.maxWeight > 0 }
    private var showReps:   Bool { !exercise.isTimeBased }
    private var showTime:   Bool { exercise.isTimeBased }

    var body: some View {
        SectionContainer(title: "Progress · last 90 days") {
            VStack(spacing: 0) {
                if weeks.allSatisfy({ !$0.hasData }) {
                    Text("No data for this period")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(32)
                } else {
                    if showReps {
                        MiniLineChart(
                            title: "Reps",
                            values: weeks.map { Double($0.totalReps) },
                            labels: weeks.map(\.label),
                            color: .purple
                        )
                        if showVolume || showWeight || showTime {
                            Divider().padding(.horizontal, 16)
                        }
                    }
                    if showVolume {
                        MiniLineChart(
                            title: "Volume",
                            values: weeks.map(\.volume),
                            labels: weeks.map(\.label),
                            color: .orange,
                            formatValue: { v in
                                v >= 1000 ? String(format: "%.0fk", v / 1000) : "\(Int(v))"
                            }
                        )
                        if showWeight {
                            Divider().padding(.horizontal, 16)
                        }
                    }
                    if showWeight {
                        MiniLineChart(
                            title: "Max weight",
                            values: weeks.map(\.maxWeight),
                            labels: weeks.map(\.label),
                            color: .blue,
                            formatValue: { "\(Int($0))kg" }
                        )
                    }
                    if showTime {
                        MiniLineChart(
                            title: "Time",
                            values: weeks.map { Double($0.totalTime) },
                            labels: weeks.map(\.label),
                            color: .teal,
                            formatValue: { v in
                                let s = Int(v); let m = s / 60; let sec = s % 60
                                return String(format: "%d:%02d", m, sec)
                            }
                        )
                    }
                }
            }
            .padding()
        }
    }
}

// MARK: - ACWRChartsSection
//struct ACWRChartsSection: View {
//    let dailyStats: [ExerciseDailyStats]
//    let exercise: ExerciseStats
//
//    private var showWeight: Bool { exercise.maxWeight > 0 }
//    private var showVolume: Bool { exercise.maxWeight > 0 || exercise.totalVolume > 0 }
//    private var showTime:   Bool { exercise.isTimeBased }
//    private var showReps:   Bool { !exercise.isTimeBased }
//
//    // Build 13 ACWR points from the same 13-week buckets.
//    // Points 0-2 have nil values (only used as chronic baseline).
//    // Points 3-12 have computed ratios.
//    private var acwrPoints: [ACWRPoint] {
//        let weeks = buildWeeks(from: dailyStats)
//
//        return weeks.enumerated().map { weekIndex, week in
//            guard weekIndex >= 3 else {
//                return ACWRPoint(id: weekIndex, label: week.label,
//                                 reps: nil, weight: nil, volume: nil, time: nil)
//            }
//
//            let chronic = Array(weeks[(weekIndex - 3)..<weekIndex])
//
//            func ratio(_ acuteVal: Double, _ chronicVals: [Double]) -> Double? {
//                let avg = chronicVals.reduce(0.0, +) / Double(chronicVals.count)
//                guard avg > 0 else { return nil }
//                return acuteVal / avg
//            }
//
//            return ACWRPoint(
//                id: weekIndex,
//                label: week.label,
//                reps:   ratio(Double(week.totalReps),   chronic.map { Double($0.totalReps) }),
//                weight: ratio(week.maxWeight,            chronic.map(\.maxWeight)),
//                volume: ratio(week.volume,               chronic.map(\.volume)),
//                time:   ratio(Double(week.totalTime),   chronic.map { Double($0.totalTime) })
//            )
//        }
//    }
//
//    // Only show this section when at least one metric has enough data
//    private var hasEnoughData: Bool {
//        acwrPoints.dropFirst(3).contains { $0.hasAnyValue }
//    }
//
//    var body: some View {
//        SectionContainer(title: "Workload ratio · last 90 days") {
//            VStack(spacing: 0) {
//                if !hasEnoughData {
//                    Text("Not enough training history to calculate workload ratio")
//                        .font(.subheadline)
//                        .foregroundStyle(.secondary)
//                        .multilineTextAlignment(.center)
//                        .frame(maxWidth: .infinity, alignment: .center)
//                        .padding(32)
//                } else {
//                    // Zone legend
//                    HStack(spacing: 12) {
//                        ForEach([
//                            ("Low", Color.blue),
//                            ("Optimal", Color.green),
//                            ("Caution", Color.orange),
//                            ("High risk", Color.red)
//                        ], id: \.0) { label, color in
//                            HStack(spacing: 4) {
//                                Circle().fill(color).frame(width: 7, height: 7)
//                                Text(label).font(.system(size: 9)).foregroundStyle(.secondary)
//                            }
//                        }
//                    }
//                    .padding(.horizontal, 16)
//                    .padding(.top, 14)
//                    .padding(.bottom, 4)
//
//                    let labels = acwrPoints.map(\.label)
//
//                    if showReps, acwrPoints.dropFirst(3).contains(where: { $0.reps != nil }) {
//                        ACWRMiniChart(
//                            title: "Reps ACWR",
//                            values: acwrPoints.map(\.reps),
//                            labels: labels
//                        )
//                        if showVolume || showWeight || showTime {
//                            Divider().padding(.horizontal, 16)
//                        }
//                    }
//                    if showVolume, acwrPoints.dropFirst(3).contains(where: { $0.volume != nil }) {
//                        ACWRMiniChart(
//                            title: "Volume ACWR",
//                            values: acwrPoints.map(\.volume),
//                            labels: labels
//                        )
//                        if showWeight {
//                            Divider().padding(.horizontal, 16)
//                        }
//                    }
//                    if showWeight, acwrPoints.dropFirst(3).contains(where: { $0.weight != nil }) {
//                        ACWRMiniChart(
//                            title: "Weight ACWR",
//                            values: acwrPoints.map(\.weight),
//                            labels: labels
//                        )
//                    }
//                    if showTime, acwrPoints.dropFirst(3).contains(where: { $0.time != nil }) {
//                        ACWRMiniChart(
//                            title: "Time ACWR",
//                            values: acwrPoints.map(\.time),
//                            labels: labels
//                        )
//                    }
//
//                    Divider().padding(.horizontal, 16)
//                    Text("Acute = 7 days · Chronic = prior 3 weeks avg")
//                        .font(.caption)
//                        .foregroundStyle(.secondary)
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                        .padding(14)
//                }
//            }
//            .padding()
//        }
//    }
//}

// MARK: - MiniLineChart
//private struct MiniLineChart: View {
//    let title: String
//    let values: [Double]
//    let labels: [String]
//    let color: Color
//    var formatValue: ((Double) -> String)? = nil
//
//    private var maxValue: Double { values.max().flatMap { $0 > 0 ? $0 : nil } ?? 1 }
//
//    private var peakLabel: String {
//        let max = values.max() ?? 0
//        return formatValue?(max) ?? "\(Int(max))"
//    }
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 6) {
//            HStack {
//                Text(title)
//                    .font(.caption).fontWeight(.semibold)
//                    .foregroundStyle(.secondary)
//                    .textCase(.uppercase).tracking(0.5)
//                Spacer()
//                Text(peakLabel)
//                    .font(.caption).fontWeight(.medium)
//                    .foregroundStyle(color)
//            }
//            .padding(.horizontal, 16)
//            .padding(.top, 14)
//
//            GeometryReader { geo in
//                let w = geo.size.width
//                let h = geo.size.height
//                ZStack(alignment: .bottomLeading) {
//                    gradientFill(values: values, width: w, height: h)
//                    linePath(values: values, width: w, height: h)
//                        .stroke(color, style: StrokeStyle(lineWidth: 2, lineJoin: .round))
//                    dotsView(values: values, width: w, height: h)
//                    xLabels(width: w, height: h)
//                }
//            }
//            .frame(height: 90)
//            .padding(.horizontal, 16)
//            .padding(.bottom, 20)
//        }
//    }
//
//    private func norm(_ v: Double) -> Double { maxValue > 0 ? v / maxValue : 0 }
//
//    private func pt(i: Int, v: Double, w: CGFloat, h: CGFloat) -> CGPoint {
//        let sx = values.count > 1 ? w / CGFloat(values.count - 1) : w
//        return CGPoint(x: CGFloat(i) * sx, y: h * CGFloat(1.0 - norm(v)))
//    }
//
//    private func linePath(values: [Double], width: CGFloat, height: CGFloat) -> Path {
//        Path { p in
//            guard values.count > 1 else { return }
//            let sx = width / CGFloat(values.count - 1)
//            for (i, v) in values.enumerated() {
//                let point = pt(i: i, v: v, w: width, h: height)
//                if i == 0 { p.move(to: point) }
//                else {
//                    let prev = pt(i: i - 1, v: values[i - 1], w: width, h: height)
//                    p.addCurve(to: point,
//                               control1: CGPoint(x: prev.x + sx * 0.4, y: prev.y),
//                               control2: CGPoint(x: point.x - sx * 0.4, y: point.y))
//                }
//            }
//        }
//    }
//
//    @ViewBuilder
//    private func gradientFill(values: [Double], width: CGFloat, height: CGFloat) -> some View {
//        Path { p in
//            guard values.count > 1 else { return }
//            let sx = width / CGFloat(values.count - 1)
//            p.move(to: CGPoint(x: 0, y: height))
//            p.addLine(to: pt(i: 0, v: values[0], w: width, h: height))
//            for i in 1..<values.count {
//                let point = pt(i: i, v: values[i], w: width, h: height)
//                let prev  = pt(i: i - 1, v: values[i - 1], w: width, h: height)
//                p.addCurve(to: point,
//                           control1: CGPoint(x: prev.x + sx * 0.4, y: prev.y),
//                           control2: CGPoint(x: point.x - sx * 0.4, y: point.y))
//            }
//            p.addLine(to: CGPoint(x: width, y: height))
//            p.closeSubpath()
//        }
//        .fill(LinearGradient(
//            colors: [color.opacity(0.3), color.opacity(0.0)],
//            startPoint: .top, endPoint: .bottom
//        ))
//    }
//
//    @ViewBuilder
//    private func dotsView(values: [Double], width: CGFloat, height: CGFloat) -> some View {
//        ForEach(Array(values.enumerated()), id: \.offset) { i, v in
//            if v > 0 {
//                Circle().fill(color).frame(width: 5, height: 5)
//                    .position(pt(i: i, v: v, w: width, h: height))
//            }
//        }
//    }
//
//    @ViewBuilder
//    private func xLabels(width: CGFloat, height: CGFloat) -> some View {
//        let sx = values.count > 1 ? width / CGFloat(values.count - 1) : width
//        ForEach([0, 6, 12], id: \.self) { i in
//            if i < labels.count {
//                Text(labels[i]).font(.system(size: 9)).foregroundStyle(.secondary)
//                    .position(x: CGFloat(i) * sx, y: height + 12)
//            }
//        }
//    }
//}

// MARK: - ACWRMiniChart
// Coloured line whose colour reflects the current zone.
// Gradient fill underneath transitions from line colour to transparent.
// Zone reference lines (dashed) at 0.8, 1.0, 1.3, 1.5.
// First 3 values are always nil (chronic baseline only) — skipped in rendering.
struct ACWRMiniChart: View {
    let title: String
    let values: [Double?]   // 13 values; first 3 always nil
    let labels: [String]    // 13 labels matching progress charts

    private let yMin: Double = 0.0
    private let yMax: Double = 2.0

    // Only the values from index 3 onwards are rendered
    private var renderValues: [(index: Int, value: Double?)] {
        values.enumerated().map { ($0.offset, $0.element) }.filter { $0.index >= 3 }
    }

    private var hasAnyValue: Bool {
        renderValues.contains { $0.value != nil }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption).fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .textCase(.uppercase).tracking(0.5)
                .padding(.horizontal, 16)
                .padding(.top, 14)

            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height

                ZStack(alignment: .bottomLeading) {
                    referenceLines(width: w, height: h)
                    if hasAnyValue {
                        gradientFill(width: w, height: h)
                        colouredLine(width: w, height: h)
                        dots(width: w, height: h)
                    }
                    xLabels(width: w, height: h)
                }
            }
            .frame(height: 90)
            .padding(.horizontal, 16)
            .padding(.bottom, 20)
        }
    }

    // X position — spans full width over all 13 indices so labels align with progress charts
    private func xPos(index: Int, width: CGFloat) -> CGFloat {
        width / CGFloat(values.count - 1) * CGFloat(index)
    }

    private func yPos(value: Double, height: CGFloat) -> CGFloat {
        let clamped = min(max(value, yMin), yMax)
        return height * CGFloat(1.0 - (clamped - yMin) / (yMax - yMin))
    }

    // Dashed horizontal lines at zone boundaries
    @ViewBuilder
    private func referenceLines(width: CGFloat, height: CGFloat) -> some View {
        ForEach([0.8, 1.0, 1.3, 1.5], id: \.self) { boundary in
            let y = yPos(value: boundary, height: height)
            let color: Color = boundary == 1.0 ? .secondary : .secondary.opacity(0.4)
            Path { p in
                p.move(to: CGPoint(x: 0, y: y))
                p.addLine(to: CGPoint(x: width, y: y))
            }
            .stroke(color, style: StrokeStyle(lineWidth: 0.5, dash: [4, 3]))
        }
    }

    // Line segments coloured by ACWR zone of the destination point
    @ViewBuilder
    private func colouredLine(width: CGFloat, height: CGFloat) -> some View {
        let nonNil = renderValues.filter { $0.value != nil }
        ForEach(nonNil.indices.dropFirst(), id: \.self) { i in
            let from = nonNil[i - 1]
            let to   = nonNil[i]
            if let fromV = from.value, let toV = to.value {
                let fromPt = CGPoint(x: xPos(index: from.index, width: width),
                                     y: yPos(value: fromV, height: height))
                let toPt   = CGPoint(x: xPos(index: to.index, width: width),
                                     y: yPos(value: toV, height: height))
                let sx = toPt.x - fromPt.x
                Path { p in
                    p.move(to: fromPt)
                    p.addCurve(to: toPt,
                               control1: CGPoint(x: fromPt.x + sx * 0.4, y: fromPt.y),
                               control2: CGPoint(x: toPt.x - sx * 0.4, y: toPt.y))
                }
                .stroke(acwrColor(toV), style: StrokeStyle(lineWidth: 2.5, lineJoin: .round))
            }
        }
    }

    // Gradient fill under the line, coloured by the zone of the line's current position
    @ViewBuilder
    private func gradientFill(width: CGFloat, height: CGFloat) -> some View {
        let nonNil = renderValues.filter { $0.value != nil }
        if let first = nonNil.first, let last = nonNil.last,
           let firstV = first.value, let lastV = last.value {
            let currentZoneColor = acwrColor(lastV)
            let firstX = xPos(index: first.index, width: width)
            let lastX  = xPos(index: last.index, width: width)

            Path { p in
                p.move(to: CGPoint(x: firstX, y: height))
                p.addLine(to: CGPoint(x: firstX, y: yPos(value: firstV, height: height)))

                for i in nonNil.indices.dropFirst() {
                    guard let toV = nonNil[i].value else { continue }
                    let from = nonNil[i - 1]
                    guard let fromV = from.value else { continue }
                    let fromPt = CGPoint(x: xPos(index: from.index, width: width),
                                         y: yPos(value: fromV, height: height))
                    let toPt   = CGPoint(x: xPos(index: nonNil[i].index, width: width),
                                         y: yPos(value: toV, height: height))
                    let sx = toPt.x - fromPt.x
                    p.addCurve(to: toPt,
                               control1: CGPoint(x: fromPt.x + sx * 0.4, y: fromPt.y),
                               control2: CGPoint(x: toPt.x - sx * 0.4, y: toPt.y))
                }

                p.addLine(to: CGPoint(x: lastX, y: height))
                p.closeSubpath()
            }
            .fill(LinearGradient(
                colors: [currentZoneColor.opacity(0.25), currentZoneColor.opacity(0.0)],
                startPoint: .top, endPoint: .bottom
            ))
        } else {
            EmptyView()
        }
    }

    // Dots coloured by their own zone value
    @ViewBuilder
    private func dots(width: CGFloat, height: CGFloat) -> some View {
        ForEach(renderValues, id: \.index) { entry in
            if let v = entry.value {
                Circle()
                    .fill(acwrColor(v))
                    .frame(width: 5, height: 5)
                    .position(x: xPos(index: entry.index, width: width),
                              y: yPos(value: v, height: height))
            }
        }
    }

    // X labels aligned across full 13-index span matching progress charts
    @ViewBuilder
    private func xLabels(width: CGFloat, height: CGFloat) -> some View {
        ForEach([0, 6, 12], id: \.self) { i in
            if i < labels.count {
                Text(labels[i]).font(.system(size: 9)).foregroundStyle(.secondary)
                    .position(x: xPos(index: i, width: width), y: height + 12)
            }
        }
    }
}
