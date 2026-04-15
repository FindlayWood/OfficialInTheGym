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
    @State private var selectedRange: ACWRRange = .twoWeeks
    
    private var acwrData: ACWRDetailData {
        ACWRDetailData(totals: totals, range: selectedRange)
    }
    
    public init(totals: [DailyTotal]) {
        self.totals = totals
    }
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Current status card
                CurrentStatusCard(acwr: acwrData.currentACWR)
                
                // Range picker
                Picker("Range", selection: $selectedRange) {
                    ForEach(ACWRRange.allCases) { range in
                        Text(range.label).tag(range)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)
                
                // ACWR progression chart
                ACWRProgressionChart(
                    title: "ACWR Progression",
                    values: acwrData.acwrValues,
                    labels: acwrData.labels
                )
                
                // Acute vs Chronic comparison
                AcuteChronicComparisonChart(
                    acuteValues: acwrData.acuteValues,
                    chronicValues: acwrData.chronicValues,
                    labels: acwrData.labels
                )
                
                // Volume breakdown chart
                MiniLineChart(
                    title: "Daily Volume",
                    values: acwrData.volumeValues,
                    labels: acwrData.labels,
                    color: .blue,
                    formatValue: { v in
                        v >= 1000 ? String(format: "%.1fk", v / 1000) : String(format: "%.0f", v)
                    }
                )
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(.separator).opacity(0.4), lineWidth: 0.5)
                )
                
                // Zone distribution
                ZoneDistributionView(distribution: acwrData.zoneDistribution)
                
                // Insights and recommendations
                InsightsView(insights: acwrData.insights)
                
                // What is ACWR? educational section
                EducationalSection()
            }
            .padding(.vertical, 20)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("Workload Analysis")
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

// MARK: - ACWRDetailData
struct ACWRDetailData {
    let totals: [DailyTotal]
    let range: ACWRRange
    
    private var last90Days: [DailyTotal] {
        let cutoff = Calendar.current.date(byAdding: .day, value: -90, to: .now)!
        return totals.filter { $0.date >= cutoff }.sorted { $0.date < $1.date }
    }
    
    var labels: [String] {
        let rangeEnd = Date.now
        let rangeStart = Calendar.current.date(byAdding: .day, value: -range.days, to: rangeEnd)!
        
        return (0..<range.days).map { offset in
            let date = Calendar.current.date(byAdding: .day, value: offset, to: rangeStart)!
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            return formatter.string(from: date)
        }
    }
    
    // Calculate ACWR for each day in the range
    var acwrValues: [Double?] {
        let fmt = DateFormatter.yyyyMMdd
        let volumeByKey = Dictionary(uniqueKeysWithValues: last90Days.map { ($0.id, $0.totalVolume) })
        
        let rangeEnd = Date.now
        let rangeStart = Calendar.current.date(byAdding: .day, value: -range.days, to: rangeEnd)!
        
        return (0..<range.days).map { offset in
            let date = Calendar.current.date(byAdding: .day, value: offset, to: rangeStart)!
            
            // Acute: average of last 7 days ending on this date
            let acuteTotal = (0..<7).reduce(0.0) { sum, i in
                let d = Calendar.current.date(byAdding: .day, value: -i, to: date)!
                return sum + (volumeByKey[fmt.string(from: d)] ?? 0)
            }
            let acute = acuteTotal / 7.0
            
            // Chronic: average of last 28 days ending on this date
            let chronicTotal = (0..<28).reduce(0.0) { sum, i in
                let d = Calendar.current.date(byAdding: .day, value: -i, to: date)!
                return sum + (volumeByKey[fmt.string(from: d)] ?? 0)
            }
            let chronic = chronicTotal / 28.0
            
            guard chronic > 0 else { return nil }
            return acute / chronic
        }
    }
    
    var acuteValues: [Double] {
        let fmt = DateFormatter.yyyyMMdd
        let volumeByKey = Dictionary(uniqueKeysWithValues: last90Days.map { ($0.id, $0.totalVolume) })
        
        let rangeEnd = Date.now
        let rangeStart = Calendar.current.date(byAdding: .day, value: -range.days, to: rangeEnd)!
        
        return (0..<range.days).map { offset in
            let date = Calendar.current.date(byAdding: .day, value: offset, to: rangeStart)!
            let total = (0..<7).reduce(0.0) { sum, i in
                let d = Calendar.current.date(byAdding: .day, value: -i, to: date)!
                return sum + (volumeByKey[fmt.string(from: d)] ?? 0)
            }
            return total / 7.0
        }
    }
    
    var chronicValues: [Double] {
        let fmt = DateFormatter.yyyyMMdd
        let volumeByKey = Dictionary(uniqueKeysWithValues: last90Days.map { ($0.id, $0.totalVolume) })
        
        let rangeEnd = Date.now
        let rangeStart = Calendar.current.date(byAdding: .day, value: -range.days, to: rangeEnd)!
        
        return (0..<range.days).map { offset in
            let date = Calendar.current.date(byAdding: .day, value: offset, to: rangeStart)!
            let total = (0..<28).reduce(0.0) { sum, i in
                let d = Calendar.current.date(byAdding: .day, value: -i, to: date)!
                return sum + (volumeByKey[fmt.string(from: d)] ?? 0)
            }
            return total / 28.0
        }
    }
    
    var volumeValues: [Double] {
        let fmt = DateFormatter.yyyyMMdd
        let volumeByKey = Dictionary(uniqueKeysWithValues: totals.map { ($0.id, $0.totalVolume) })
        
        let rangeEnd = Date.now
        let rangeStart = Calendar.current.date(byAdding: .day, value: -range.days, to: rangeEnd)!
        
        return (0..<range.days).map { offset in
            let date = Calendar.current.date(byAdding: .day, value: offset, to: rangeStart)!
            return volumeByKey[fmt.string(from: date)] ?? 0
        }
    }
    
    var currentACWR: ACWR {
        let fmt = DateFormatter.yyyyMMdd
        let volumeByKey = Dictionary(uniqueKeysWithValues: totals.map { ($0.id, $0.totalVolume) })
        
        func average(over days: Int) -> Double {
            let total = (0..<days).reduce(0.0) { sum, offset in
                let date = Calendar.current.date(byAdding: .day, value: -offset, to: .now)!
                return sum + (volumeByKey[fmt.string(from: date)] ?? 0)
            }
            return total / Double(days)
        }
        
        let acute = average(over: 7)
        let chronic = average(over: 28)
        guard chronic > 0 else { return ACWR(acute: acute, chronic: chronic, ratio: nil) }
        return ACWR(acute: acute, chronic: chronic, ratio: acute / chronic)
    }
    
    var zoneDistribution: ZoneDistribution {
        let validRatios = acwrValues.compactMap { $0 }
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
        
        // Current zone insight
        let zone = currentACWR.zone
        results.append(.currentZone(zone, currentACWR.formattedRatio))
        
        // Trend analysis
        let recentValues = acwrValues.suffix(7).compactMap { $0 }
        if recentValues.count >= 2 {
            let trend = recentValues.last! - recentValues.first!
            if trend > 0.2 {
                results.append(.risingTrend)
            } else if trend < -0.2 {
                results.append(.fallingTrend)
            }
        }
        
        // Time in danger zone
        let dangerDays = acwrValues.compactMap { $0 }.filter { $0 >= 1.5 }.count
        if dangerDays >= 3 {
            results.append(.dangerZoneWarning(dangerDays))
        }
        
        // Recovery recommendation
        if zone == .danger || zone == .caution {
            results.append(.recoveryRecommended)
        }
        
        // Low load warning
        if zone == .low {
            let lowDays = acwrValues.suffix(7).compactMap { $0 }.filter { $0 < 0.8 }.count
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
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Current Status")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    
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
        .padding(20)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(acwr.zone.color.opacity(0.3), lineWidth: 2)
        )
        .padding(.horizontal, 16)
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
            .padding(.bottom, 20)
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.separator).opacity(0.4), lineWidth: 0.5)
        )
        .padding(.horizontal, 16)
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
            .fill(Color.red.opacity(0.05))
            .frame(width: width, height: yPos(value: 1.5, height: height))
        
        // Caution zone (1.3-1.5)
        Rectangle()
            .fill(Color.orange.opacity(0.05))
            .frame(width: width, height: yPos(value: 1.3, height: height) - yPos(value: 1.5, height: height))
            .offset(y: yPos(value: 1.5, height: height))
        
        // Optimal zone (0.8-1.3)
        Rectangle()
            .fill(Color.green.opacity(0.05))
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
                .stroke(acwrColor(toV), style: StrokeStyle(lineWidth: 2.5, lineJoin: .round))
            }
        }
    }
    
    @ViewBuilder
    private func gradientFill(width: CGFloat, height: CGFloat) -> some View {
        let nonNil = values.enumerated().filter { $0.element != nil }
        if let first = nonNil.first, let last = nonNil.last,
           let firstV = first.element, let lastV = last.element {
            let currentZoneColor = acwrColor(lastV)
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
                    .fill(acwrColor(v))
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

// Helper function
private func acwrColor(_ ratio: Double) -> Color {
    switch ratio {
    case ..<0.8: return .blue
    case 0.8..<1.3: return .green
    case 1.3..<1.5: return .orange
    default: return .red
    }
}

// MARK: - AcuteChronicComparisonChart
struct AcuteChronicComparisonChart: View {
    let acuteValues: [Double]
    let chronicValues: [Double]
    let labels: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Acute vs Chronic Load")
                    .font(.caption).fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase).tracking(0.5)
                
                Spacer()
                
                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Circle().fill(Color.orange).frame(width: 8, height: 8)
                        Text("Acute (7d)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    HStack(spacing: 4) {
                        Circle().fill(Color.purple).frame(width: 8, height: 8)
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
                        .stroke(Color.purple.opacity(0.6), style: StrokeStyle(lineWidth: 2, lineJoin: .round))
                    
                    // Acute line (in front)
                    linePath(values: acuteValues, width: w, height: h, maxValue: maxValue)
                        .stroke(Color.orange, style: StrokeStyle(lineWidth: 2.5, lineJoin: .round))
                    
                    xLabels(width: w, height: h)
                }
            }
            .frame(height: 100)
            .padding(.horizontal, 16)
            .padding(.bottom, 20)
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.separator).opacity(0.4), lineWidth: 0.5)
        )
        .padding(.horizontal, 16)
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

// MARK: - MiniLineChart (copied from example)
struct MiniLineChart: View {
    let title: String
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
                Text(title)
                    .font(.caption).fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase).tracking(0.5)
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
        VStack(alignment: .leading, spacing: 12) {
            Text("Time in Each Zone")
                .font(.caption).fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .textCase(.uppercase).tracking(0.5)
            
            VStack(spacing: 8) {
                ZoneBar(label: "Optimal", percentage: distribution.optimal, color: .green)
                ZoneBar(label: "Caution", percentage: distribution.caution, color: .orange)
                ZoneBar(label: "High Risk", percentage: distribution.danger, color: .red)
                ZoneBar(label: "Low Load", percentage: distribution.low, color: .blue)
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.separator).opacity(0.4), lineWidth: 0.5)
        )
        .padding(.horizontal, 16)
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
        case .risingTrend: return .orange
        case .fallingTrend: return .blue
        case .dangerZoneWarning: return .red
        case .recoveryRecommended: return .orange
        case .lowLoadWarning: return .blue
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
        VStack(alignment: .leading, spacing: 12) {
            Text("Insights & Recommendations")
                .font(.caption).fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .textCase(.uppercase).tracking(0.5)
            
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
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.separator).opacity(0.4), lineWidth: 0.5)
        )
        .padding(.horizontal, 16)
    }
}

// MARK: - Educational Section
struct EducationalSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("What is ACWR?")
                .font(.headline)
            
            Text("The Acute:Chronic Workload Ratio (ACWR) compares your recent training load (last 7 days) to your longer-term average (last 28 days).")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Divider()
                .padding(.vertical, 4)
            
            VStack(alignment: .leading, spacing: 8) {
                ZoneExplanation(
                    zone: "Optimal (0.8 - 1.3)",
                    color: .green,
                    explanation: "Your training is well-balanced. Maintain this range for optimal adaptation."
                )
                
                ZoneExplanation(
                    zone: "Caution (1.3 - 1.5)",
                    color: .orange,
                    explanation: "Recent load is elevated. Monitor recovery and consider adjusting volume."
                )
                
                ZoneExplanation(
                    zone: "High Risk (1.5+)",
                    color: .red,
                    explanation: "Significant spike in training load. High injury risk - prioritize recovery."
                )
                
                ZoneExplanation(
                    zone: "Low Load (<0.8)",
                    color: .blue,
                    explanation: "Training volume is low. Gradually increase when ready."
                )
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.separator).opacity(0.4), lineWidth: 0.5)
        )
        .padding(.horizontal, 16)
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
#Preview {
    NavigationStack {
        ACWRDetailScreen(totals: MockDailyTotalsProvider().previewTotals)
    }
}
