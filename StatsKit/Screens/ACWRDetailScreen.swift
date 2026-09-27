//
//  ACWRDetailScreen.swift
//  StatsKit
//
//  Created by Findlay Wood on 12/04/2026.
//

import SwiftUI

// MARK: - ACWRDetailScreen
public struct ACWRDetailScreen: View {
    let totals: [DailyTotal]
    let metric: TrainingLoadMetric
    @State private var selectedRange: ACWRRange = .twoWeeks

    private var acwrData: ACWRDetailData {
        ACWRDetailData(totals: totals, range: selectedRange, metric: metric)
    }

    public init(totals: [DailyTotal], metric: TrainingLoadMetric) {
        self.totals = totals
        self.metric = metric
    }

    public var body: some View {
        // Bound once: every series below comes from one pass over the range,
        // and `acwrData` is a computed property that would otherwise rebuild
        // the whole thing per access.
        let series = acwrData.series

        return ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Current status card
                CurrentStatusCard(acwr: acwrData.currentACWR, metric: metric)

                // Range picker
                Picker("Range", selection: $selectedRange) {
                    ForEach(ACWRRange.allCases) { range in
                        Text(range.label).tag(range)
                    }
                }
                .pickerStyle(.segmented)

                // ACWR progression chart
                ACWRProgressionChart(
                    title: "ACWR Progression",
                    values: series.acwr,
                    labels: series.labels
                )

                // Acute vs Chronic comparison
                AcuteChronicComparisonChart(
                    acuteValues: series.acute,
                    chronicValues: series.chronic,
                    labels: series.labels
                )

                // Daily load breakdown
                SectionContainer(title: "Daily \(metric.title)") {
                    MiniLineChart(
                        values: series.load,
                        labels: series.labels,
                        color: .matteBlue,
                        formatValue: { v in
                            v >= 1000 ? String(format: "%.1fk", v / 1000) : String(format: "%.0f", v)
                        }
                    )
                }

                // Zone distribution
                ZoneDistributionView(distribution: acwrData.zoneDistribution)

                // Insights and recommendations
                InsightsView(insights: acwrData.insights)

                // What is ACWR? educational section
                EducationalSection(metric: metric)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        // The same page/card relationship as the home screen and
        // `ExerciseDetailScreen`: `darkColor` behind `systemBackground` cards.
        // This was `systemGroupedBackground`, so pushing from the stats home
        // into a detail screen changed the whole frame of the app.
        .background { Color.darkColor.ignoresSafeArea() }
        .navigationTitle(metric.title)
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - ACWRRange
enum ACWRRange: String, CaseIterable, Identifiable {
    case twoWeeks = "2W"
    case month = "1M"
    case twoMonths = "2M"
    
    var id: String { rawValue }
    
    var label: String { rawValue }
    
    var days: Int {
        switch self {
        case .twoWeeks: return 14
        case .month: return 30
        case .twoMonths: return 60
        }
    }
}

// MARK: - ACWRSeries
/// Every series the screen draws, over the same x-axis.
///
/// Built in one pass because `ACWR.rolling` already returns acute, chronic and
/// the ratio together — asking for them separately walked the same 28-day
/// window three times per day on screen.
struct ACWRSeries {
    let labels: [String]
    let acwr: [Double?]
    let acute: [Double]
    let chronic: [Double]
    let load: [Double]
}

// MARK: - ACWRDetailData
struct ACWRDetailData {
    let totals: [DailyTotal]
    let range: ACWRRange
    let metric: TrainingLoadMetric

    /// Labels are formatted in the same calendar the day keys are built in, so
    /// a point's label and its data can never be a day apart.
    private static let labelFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        formatter.timeZone = StatsDay.calendar.timeZone
        return formatter
    }()

    /// The days on the x-axis, oldest first, **including today**.
    ///
    /// The range used to end at yesterday, so the ratio in the status card —
    /// which is always as of now — was one the chart never plotted.
    private var days: [Date] {
        (0..<range.days).reversed().map { StatsDay.date(daysAgo: $0) }
    }

    var series: ACWRSeries {
        let loads = totals.loadByDay(metric)
        var labels: [String] = []
        var acwr: [Double?] = []
        var acute: [Double] = []
        var chronic: [Double] = []
        var load: [Double] = []

        for day in days {
            let rolling = ACWR.rolling(loadByDay: loads, endingOn: day)
            labels.append(Self.labelFormatter.string(from: day))
            acwr.append(rolling.ratio)
            acute.append(rolling.acute)
            chronic.append(rolling.chronic)
            load.append(loads[StatsDay.key(for: day)] ?? 0)
        }

        return ACWRSeries(
            labels: labels, acwr: acwr, acute: acute, chronic: chronic, load: load
        )
    }

    var currentACWR: ACWR {
        ACWR.rolling(loadByDay: totals.loadByDay(metric))
    }

    var zoneDistribution: ZoneDistribution {
        let validRatios = series.acwr.compactMap { $0 }
        guard !validRatios.isEmpty else {
            return ZoneDistribution(optimal: 0, caution: 0, danger: 0, low: 0)
        }
        
        let total = Double(validRatios.count)
        let optimal = validRatios.filter { (0.8..<1.3).contains($0) }.count
        let caution = validRatios.filter { (1.3..<1.5).contains($0) }.count
        let danger = validRatios.filter { $0 >= 1.5 }.count
        let low = validRatios.filter { $0 < 0.8 }.count
        
        return ZoneDistribution(
            optimal: Double(optimal) / total,
            caution: Double(caution) / total,
            danger: Double(danger) / total,
            low: Double(low) / total
        )
    }
    
    var insights: [ACWRInsight] {
        var results: [ACWRInsight] = []
        let ratios = series.acwr

        // Current zone insight
        let current = currentACWR
        let zone = current.zone
        results.append(.currentZone(zone, current.formattedRatio))

        // Trend analysis
        let recentValues = ratios.suffix(7).compactMap { $0 }
        if recentValues.count >= 2, let first = recentValues.first, let last = recentValues.last {
            let trend = last - first
            if trend > 0.2 {
                results.append(.risingTrend)
            } else if trend < -0.2 {
                results.append(.fallingTrend)
            }
        }

        // Time in danger zone
        let dangerDays = ratios.compactMap { $0 }.filter { $0 >= 1.5 }.count
        if dangerDays >= 3 {
            results.append(.dangerZoneWarning(dangerDays))
        }

        // Recovery recommendation
        if zone == .danger || zone == .caution {
            results.append(.recoveryRecommended)
        }
        
        // Low load warning
        if zone == .low {
            let lowDays = ratios.suffix(7).compactMap { $0 }.filter { $0 < 0.8 }.count
            if lowDays >= 5 {
                results.append(.lowLoadWarning)
            }
        }
        
        return results
    }
}

// MARK: - CurrentStatusCard
struct CurrentStatusCard: View {
    let acwr: ACWR
    let metric: TrainingLoadMetric

    var body: some View {
        SectionContainer(title: "Current status") {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    // The acute and chronic figures below are bare numbers; this
                    // is the only thing on the card that says what they are
                    // counting, which matters now there are two metrics.
                    Text(metric.subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    HStack(spacing: 8) {
                        Text(acwr.formattedRatio)
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundStyle(acwr.zone.color)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(acwr.zone.label)
                                .font(.subheadline).fontWeight(.semibold)
                                .foregroundStyle(acwr.zone.color)
                            
                            Text("ACWR")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                
                Spacer()
                
                // Zone indicator
                ZStack {
                    Circle()
                        .fill(acwr.zone.color.opacity(0.15))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: zoneIcon)
                        .font(.system(size: 32))
                        .foregroundStyle(acwr.zone.color)
                }
            }
            
            Divider()
            
            // Acute and Chronic values
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Acute (7-day)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(String(format: "%.0f", acwr.acute))
                        .font(.title3).fontWeight(.semibold)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Chronic (28-day)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(String(format: "%.0f", acwr.chronic))
                        .font(.title3).fontWeight(.semibold)
                }
            }
        }
        .padding(16)
        }
    }

    private var zoneIcon: String {
        switch acwr.zone {
        case .optimal: return "checkmark.circle.fill"
        case .caution: return "exclamationmark.triangle.fill"
        case .danger: return "xmark.octagon.fill"
        case .low: return "arrow.down.circle.fill"
        case .insufficient: return "questionmark.circle.fill"
        }
    }
}

// MARK: - ACWRProgressionChart
struct ACWRProgressionChart: View {
    let title: String
    let values: [Double?]
    let labels: [String]
    
    private let yMin: Double = 0.0
    private let yMax: Double = 2.0
    
    private var hasAnyValue: Bool {
        values.contains { $0 != nil }
    }
    
    var body: some View {
        SectionContainer(title: title) {
        VStack(alignment: .leading, spacing: 6) {
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                
                ZStack(alignment: .bottomLeading) {
                    // Zone background bands
                    zoneBackgrounds(width: w, height: h)
                    
                    // Reference lines
                    referenceLines(width: w, height: h)
                    
                    if hasAnyValue {
                        gradientFill(width: w, height: h)
                        colouredLine(width: w, height: h)
                        dots(width: w, height: h)
                    }
                    xLabels(width: w, height: h)
                }
            }
            .frame(height: 120)
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 20)
        }
        }
    }
    
    private func xPos(index: Int, width: CGFloat) -> CGFloat {
        width / CGFloat(values.count - 1) * CGFloat(index)
    }
    
    private func yPos(value: Double, height: CGFloat) -> CGFloat {
        let clamped = min(max(value, yMin), yMax)
        return height * CGFloat(1.0 - (clamped - yMin) / (yMax - yMin))
    }
    
    @ViewBuilder
    private func zoneBackgrounds(width: CGFloat, height: CGFloat) -> some View {
        // Danger zone (1.5+)
        Rectangle()
            .fill(ACWR.Zone.danger.color.opacity(0.07))
            .frame(width: width, height: yPos(value: 1.5, height: height))
        
        // Caution zone (1.3-1.5)
        Rectangle()
            .fill(ACWR.Zone.caution.color.opacity(0.07))
            .frame(width: width, height: yPos(value: 1.3, height: height) - yPos(value: 1.5, height: height))
            .offset(y: yPos(value: 1.5, height: height))
        
        // Optimal zone (0.8-1.3)
        Rectangle()
            .fill(ACWR.Zone.optimal.color.opacity(0.07))
            .frame(width: width, height: yPos(value: 0.8, height: height) - yPos(value: 1.3, height: height))
            .offset(y: yPos(value: 1.3, height: height))
    }
    
    @ViewBuilder
    private func referenceLines(width: CGFloat, height: CGFloat) -> some View {
        ForEach([0.8, 1.0, 1.3, 1.5], id: \.self) { boundary in
            let y = yPos(value: boundary, height: height)
            let color: Color = boundary == 1.0 ? .secondary : .secondary.opacity(0.3)
            Path { p in
                p.move(to: CGPoint(x: 0, y: y))
                p.addLine(to: CGPoint(x: width, y: y))
            }
            .stroke(color, style: StrokeStyle(lineWidth: 0.5, dash: [4, 3]))
            
            // Label
            if boundary != 1.0 {
                Text(String(format: "%.1f", boundary))
                    .font(.system(size: 8))
                    .foregroundStyle(.secondary)
                    .position(x: width - 15, y: y - 8)
            }
        }
    }
    
    @ViewBuilder
    private func colouredLine(width: CGFloat, height: CGFloat) -> some View {
        let nonNil = values.enumerated().filter { $0.element != nil }
        ForEach(nonNil.indices.dropFirst(), id: \.self) { i in
            let from = nonNil[i - 1]
            let to = nonNil[i]
            if let fromV = from.element, let toV = to.element {
                let fromPt = CGPoint(x: xPos(index: from.offset, width: width),
                                     y: yPos(value: fromV, height: height))
                let toPt = CGPoint(x: xPos(index: to.offset, width: width),
                                   y: yPos(value: toV, height: height))
                let sx = toPt.x - fromPt.x
                Path { p in
                    p.move(to: fromPt)
                    p.addCurve(to: toPt,
                               control1: CGPoint(x: fromPt.x + sx * 0.4, y: fromPt.y),
                               control2: CGPoint(x: toPt.x - sx * 0.4, y: toPt.y))
                }
                .stroke(ACWR.Zone(ratio: toV).color, style: StrokeStyle(lineWidth: 2.5, lineJoin: .round))
            }
        }
    }
    
    @ViewBuilder
    private func gradientFill(width: CGFloat, height: CGFloat) -> some View {
        let nonNil = values.enumerated().filter { $0.element != nil }
        if let first = nonNil.first, let last = nonNil.last,
           let firstV = first.element, let lastV = last.element {
            let currentZoneColor = ACWR.Zone(ratio: lastV).color
            let firstX = xPos(index: first.offset, width: width)
            let lastX = xPos(index: last.offset, width: width)
            
            Path { p in
                p.move(to: CGPoint(x: firstX, y: height))
                p.addLine(to: CGPoint(x: firstX, y: yPos(value: firstV, height: height)))
                
                for i in nonNil.indices.dropFirst() {
                    guard let toV = nonNil[i].element else { continue }
                    let from = nonNil[i - 1]
                    guard let fromV = from.element else { continue }
                    let fromPt = CGPoint(x: xPos(index: from.offset, width: width),
                                         y: yPos(value: fromV, height: height))
                    let toPt = CGPoint(x: xPos(index: nonNil[i].offset, width: width),
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
                colors: [currentZoneColor.opacity(0.2), currentZoneColor.opacity(0.0)],
                startPoint: .top, endPoint: .bottom
            ))
        }
    }
    
    @ViewBuilder
    private func dots(width: CGFloat, height: CGFloat) -> some View {
        ForEach(values.enumerated().filter { $0.element != nil }.map { $0.offset }, id: \.self) { i in
            if let v = values[i] {
                Circle()
                    .fill(ACWR.Zone(ratio: v).color)
                    .frame(width: 5, height: 5)
                    .position(x: xPos(index: i, width: width),
                              y: yPos(value: v, height: height))
            }
        }
    }
    
    @ViewBuilder
    private func xLabels(width: CGFloat, height: CGFloat) -> some View {
        let step = max(1, labels.count / 3)
        ForEach(stride(from: 0, to: labels.count, by: step).map { $0 }, id: \.self) { i in
            if i < labels.count {
                Text(labels[i])
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
                    .position(x: xPos(index: i, width: width), y: height + 12)
            }
        }
    }
}


// MARK: - AcuteChronicComparisonChart
struct AcuteChronicComparisonChart: View {
    let acuteValues: [Double]
    let chronicValues: [Double]
    let labels: [String]
    
    var body: some View {
        SectionContainer(title: "Acute vs Chronic Load") {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Spacer()

                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Circle().fill(Color.matteAmber).frame(width: 8, height: 8)
                        Text("Acute (7d)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    HStack(spacing: 4) {
                        Circle().fill(Color.mattePlum).frame(width: 8, height: 8)
                        Text("Chronic (28d)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
            
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                let maxValue = max(acuteValues.max() ?? 1, chronicValues.max() ?? 1)
                
                ZStack(alignment: .bottomLeading) {
                    // Chronic line (behind)
                    linePath(values: chronicValues, width: w, height: h, maxValue: maxValue)
                        .stroke(Color.mattePlum.opacity(0.75), style: StrokeStyle(lineWidth: 2, lineJoin: .round))
                    
                    // Acute line (in front)
                    linePath(values: acuteValues, width: w, height: h, maxValue: maxValue)
                        .stroke(Color.matteAmber, style: StrokeStyle(lineWidth: 2.5, lineJoin: .round))
                    
                    xLabels(width: w, height: h)
                }
            }
            .frame(height: 100)
            .padding(.horizontal, 16)
            .padding(.bottom, 20)
        }
        }
    }
    
    private func linePath(values: [Double], width: CGFloat, height: CGFloat, maxValue: Double) -> Path {
        Path { p in
            guard values.count > 1 else { return }
            let sx = width / CGFloat(values.count - 1)
            
            for (i, v) in values.enumerated() {
                let norm = maxValue > 0 ? v / maxValue : 0
                let point = CGPoint(x: CGFloat(i) * sx, y: height * CGFloat(1.0 - norm))
                
                if i == 0 {
                    p.move(to: point)
                } else {
                    let prev = CGPoint(x: CGFloat(i - 1) * sx,
                                       y: height * CGFloat(1.0 - (values[i - 1] / maxValue)))
                    p.addCurve(to: point,
                               control1: CGPoint(x: prev.x + sx * 0.4, y: prev.y),
                               control2: CGPoint(x: point.x - sx * 0.4, y: point.y))
                }
            }
        }
    }
    
    @ViewBuilder
    private func xLabels(width: CGFloat, height: CGFloat) -> some View {
        let step = max(1, labels.count / 3)
        ForEach(stride(from: 0, to: labels.count, by: step).map { $0 }, id: \.self) { i in
            if i < labels.count {
                let sx = width / CGFloat(labels.count - 1)
                Text(labels[i])
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
                    .position(x: CGFloat(i) * sx, y: height + 12)
            }
        }
    }
}

// MARK: - MiniLineChart
/// **`title` is optional because the chart is used at two levels.**
/// `ProgressChartSection` stacks three of them inside one `SectionContainer`, so
/// each needs its own sub-heading ("Reps", "Volume", "Max weight"). On
/// `ACWRDetailScreen` it is the only content in its card, and the container's
/// own header names it — a title here as well would print the heading twice.
struct MiniLineChart: View {
    var title: String? = nil
    let values: [Double]
    let labels: [String]
    let color: Color
    var formatValue: ((Double) -> String)? = nil

    private var maxValue: Double { values.max().flatMap { $0 > 0 ? $0 : nil } ?? 1 }

    private var peakLabel: String {
        let max = values.max() ?? 0
        return formatValue?(max) ?? "\(Int(max))"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                if let title {
                    Text(title)
                        .font(.caption).fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase).tracking(0.5)
                }
                Spacer()
                Text(peakLabel)
                    .font(.caption).fontWeight(.medium)
                    .foregroundStyle(color)
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)

            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                ZStack(alignment: .bottomLeading) {
                    gradientFill(values: values, width: w, height: h)
                    linePath(values: values, width: w, height: h)
                        .stroke(color, style: StrokeStyle(lineWidth: 2, lineJoin: .round))
                    dotsView(values: values, width: w, height: h)
                    xLabels(width: w, height: h)
                }
            }
            .frame(height: 90)
            .padding(.horizontal, 16)
            .padding(.bottom, 20)
        }
    }

    private func norm(_ v: Double) -> Double { maxValue > 0 ? v / maxValue : 0 }

    private func pt(i: Int, v: Double, w: CGFloat, h: CGFloat) -> CGPoint {
        let sx = values.count > 1 ? w / CGFloat(values.count - 1) : w
        return CGPoint(x: CGFloat(i) * sx, y: h * CGFloat(1.0 - norm(v)))
    }

    private func linePath(values: [Double], width: CGFloat, height: CGFloat) -> Path {
        Path { p in
            guard values.count > 1 else { return }
            let sx = width / CGFloat(values.count - 1)
            for (i, v) in values.enumerated() {
                let point = pt(i: i, v: v, w: width, h: height)
                if i == 0 { p.move(to: point) }
                else {
                    let prev = pt(i: i - 1, v: values[i - 1], w: width, h: height)
                    p.addCurve(to: point,
                               control1: CGPoint(x: prev.x + sx * 0.4, y: prev.y),
                               control2: CGPoint(x: point.x - sx * 0.4, y: point.y))
                }
            }
        }
    }

    @ViewBuilder
    private func gradientFill(values: [Double], width: CGFloat, height: CGFloat) -> some View {
        Path { p in
            guard values.count > 1 else { return }
            let sx = width / CGFloat(values.count - 1)
            p.move(to: CGPoint(x: 0, y: height))
            p.addLine(to: pt(i: 0, v: values[0], w: width, h: height))
            for i in 1..<values.count {
                let point = pt(i: i, v: values[i], w: width, h: height)
                let prev  = pt(i: i - 1, v: values[i - 1], w: width, h: height)
                p.addCurve(to: point,
                           control1: CGPoint(x: prev.x + sx * 0.4, y: prev.y),
                           control2: CGPoint(x: point.x - sx * 0.4, y: point.y))
            }
            p.addLine(to: CGPoint(x: width, y: height))
            p.closeSubpath()
        }
        .fill(LinearGradient(
            colors: [color.opacity(0.3), color.opacity(0.0)],
            startPoint: .top, endPoint: .bottom
        ))
    }

    @ViewBuilder
    private func dotsView(values: [Double], width: CGFloat, height: CGFloat) -> some View {
        ForEach(Array(values.enumerated()), id: \.offset) { i, v in
            if v > 0 {
                Circle().fill(color).frame(width: 5, height: 5)
                    .position(pt(i: i, v: v, w: width, h: height))
            }
        }
    }

    @ViewBuilder
    private func xLabels(width: CGFloat, height: CGFloat) -> some View {
        let step = max(1, values.count / 3)
        ForEach(stride(from: 0, to: labels.count, by: step).map { $0 }, id: \.self) { i in
            if i < labels.count {
                let sx = values.count > 1 ? width / CGFloat(values.count - 1) : width
                Text(labels[i]).font(.system(size: 9)).foregroundStyle(.secondary)
                    .position(x: CGFloat(i) * sx, y: height + 12)
            }
        }
    }
}

// MARK: - ZoneDistribution
struct ZoneDistribution {
    let optimal: Double
    let caution: Double
    let danger: Double
    let low: Double
}

struct ZoneDistributionView: View {
    let distribution: ZoneDistribution
    
    var body: some View {
        SectionContainer(title: "Time in Each Zone") {
        VStack(alignment: .leading, spacing: 12) {
            VStack(spacing: 8) {
                ZoneBar(label: "Optimal", percentage: distribution.optimal, color: ACWR.Zone.optimal.color)
                ZoneBar(label: "Caution", percentage: distribution.caution, color: ACWR.Zone.caution.color)
                ZoneBar(label: "High Risk", percentage: distribution.danger, color: ACWR.Zone.danger.color)
                ZoneBar(label: "Low Load", percentage: distribution.low, color: ACWR.Zone.low.color)
            }
        }
        .padding(16)
        }
    }
}

struct ZoneBar: View {
    let label: String
    let percentage: Double
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.primary)
                .frame(width: 80, alignment: .leading)
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.tertiarySystemFill))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: geo.size.width * CGFloat(percentage), height: 8)
                }
            }
            .frame(height: 8)
            
            Text(String(format: "%.0f%%", percentage * 100))
                .font(.caption).fontWeight(.medium)
                .foregroundStyle(.secondary)
                .frame(width: 40, alignment: .trailing)
        }
    }
}

// MARK: - Insights
enum ACWRInsight: Identifiable {
    case currentZone(ACWR.Zone, String)
    case risingTrend
    case fallingTrend
    case dangerZoneWarning(Int)
    case recoveryRecommended
    case lowLoadWarning
    
    var id: String {
        switch self {
        case .currentZone: return "currentZone"
        case .risingTrend: return "risingTrend"
        case .fallingTrend: return "fallingTrend"
        case .dangerZoneWarning: return "dangerZone"
        case .recoveryRecommended: return "recovery"
        case .lowLoadWarning: return "lowLoad"
        }
    }
    
    var icon: String {
        switch self {
        case .currentZone(let zone, _):
            switch zone {
            case .optimal: return "checkmark.circle.fill"
            case .caution: return "exclamationmark.triangle.fill"
            case .danger: return "xmark.octagon.fill"
            case .low: return "arrow.down.circle.fill"
            case .insufficient: return "questionmark.circle.fill"
            }
        case .risingTrend: return "arrow.up.right"
        case .fallingTrend: return "arrow.down.right"
        case .dangerZoneWarning: return "exclamationmark.triangle.fill"
        case .recoveryRecommended: return "bed.double.fill"
        case .lowLoadWarning: return "arrow.up.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .currentZone(let zone, _): return zone.color
        case .risingTrend: return .matteAmber
        case .fallingTrend: return .matteBlue
        case .dangerZoneWarning: return ACWR.Zone.danger.color
        case .recoveryRecommended: return .matteAmber
        case .lowLoadWarning: return .matteBlue
        }
    }
    
    var title: String {
        switch self {
        case .currentZone(let zone, _): return zone.label
        case .risingTrend: return "Rising Trend"
        case .fallingTrend: return "Decreasing Load"
        case .dangerZoneWarning: return "Extended High Risk"
        case .recoveryRecommended: return "Recovery Needed"
        case .lowLoadWarning: return "Deload Period"
        }
    }
    
    var message: String {
        switch self {
        case .currentZone(let zone, let ratio):
            return "Your current ACWR is \(ratio), which is in the \(zone.label.lowercased()) zone."
        case .risingTrend:
            return "Your workload has been increasing. Monitor closely to avoid overtraining."
        case .fallingTrend:
            return "Your recent training load is decreasing. Consider gradually ramping back up."
        case .dangerZoneWarning(let days):
            return "You've been in the high risk zone for \(days) days. Prioritize recovery."
        case .recoveryRecommended:
            return "Consider reducing volume or taking a rest day to allow recovery."
        case .lowLoadWarning:
            return "You've been training at a low volume. Gradually increase load when ready."
        }
    }
}

struct InsightsView: View {
    let insights: [ACWRInsight]
    
    var body: some View {
        SectionContainer(title: "Insights & Recommendations") {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(insights) { insight in
                HStack(spacing: 12) {
                    Image(systemName: insight.icon)
                        .font(.title3)
                        .foregroundStyle(insight.color)
                        .frame(width: 32)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(insight.title)
                            .font(.subheadline).fontWeight(.medium)
                        Text(insight.message)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(12)
                .background(insight.color.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(16)
        }
    }
}

// MARK: - Educational Section
struct EducationalSection: View {
    let metric: TrainingLoadMetric

    var body: some View {
        SectionContainer(title: "What is ACWR?") {
        VStack(alignment: .leading, spacing: 12) {
            Text("The Acute:Chronic Workload Ratio (ACWR) compares your recent training load (last 7 days) to your longer-term average (last 28 days).")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            // Which work this particular ratio counted, and — just as important
            // — which it did not. Two ratios that look alike but measure
            // different training need to say so somewhere.
            VStack(alignment: .leading, spacing: 4) {
                Text(metric.title)
                    .font(.subheadline).fontWeight(.medium)
                Text(metric.explanation)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(Color(.tertiarySystemFill))
            .clipShape(RoundedRectangle(cornerRadius: 12))

            Divider()
                .padding(.vertical, 4)

            VStack(alignment: .leading, spacing: 8) {
                ZoneExplanation(
                    zone: "Optimal (0.8 - 1.3)",
                    color: ACWR.Zone.optimal.color,
                    explanation: "Your training is well-balanced. Maintain this range for optimal adaptation."
                )
                
                ZoneExplanation(
                    zone: "Caution (1.3 - 1.5)",
                    color: ACWR.Zone.caution.color,
                    explanation: "Recent load is elevated. Monitor recovery and consider adjusting volume."
                )
                
                ZoneExplanation(
                    zone: "High Risk (1.5+)",
                    color: ACWR.Zone.danger.color,
                    explanation: "Significant spike in training load. High injury risk - prioritize recovery."
                )
                
                ZoneExplanation(
                    zone: "Low Load (<0.8)",
                    color: ACWR.Zone.low.color,
                    explanation: "Training volume is low. Gradually increase when ready."
                )
            }
        }
        .padding(16)
        }
    }
}

struct ZoneExplanation: View {
    let zone: String
    let color: Color
    let explanation: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
                .padding(.top, 6)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(zone)
                    .font(.subheadline).fontWeight(.medium)
                Text(explanation)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Preview
#Preview("Session load") {
    NavigationStack {
        ACWRDetailScreen(
            totals: MockDailyTotalsProvider().previewTotals,
            metric: .session
        )
    }
}

#Preview("Volume") {
    NavigationStack {
        ACWRDetailScreen(
            totals: MockDailyTotalsProvider().previewTotals,
            metric: .volume
        )
    }
}
