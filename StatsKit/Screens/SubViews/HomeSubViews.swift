//
//  HomeSubViews.swift
//  StatsKit
//
//  Created by Findlay Wood on 22/03/2026.
//

import SwiftUI

// MARK: - HomeScreenContent
public struct HomeScreenContent: View {
    let totals: [DailyTotal]
    let exercises: [ExerciseStats]
    let muscleGroups: [MuscleGroup]
    let bodyMetrics: BodyMetrics?
    let onSeeAllExercises: () -> Void
    let onACWRDetail: () -> Void
    let onExerciseTapped: (ExerciseStats) -> Void
    let onBodyMetricsDetail: () -> Void
    let onTrainingBalanceTapped: () -> Void

    private var stats: HomeStats { HomeStats(totals: totals) }
    
    private var balanceData: TrainingBalanceData {
        TrainingBalanceData(totals: totals, range: .month, muscleGroups: muscleGroups)
    }

    private var recentExercises: [ExerciseStats] {
        Array(exercises
            .sorted { $0.lastRecordDate > $1.lastRecordDate }
            .prefix(3))
    }

    public init(
        totals: [DailyTotal],
        exercises: [ExerciseStats],
        muscleGroups: [MuscleGroup],
        bodyMetrics: BodyMetrics? = nil,
        onSeeAllExercises: @escaping () -> Void,
        onACWRDetail: @escaping () -> Void,
        onExerciseTapped: @escaping (ExerciseStats) -> Void,
        onBodyMetricsDetail: @escaping () -> Void,
        onTrainingBalanceTapped: @escaping () -> Void
    ) {
        self.totals = totals
        self.exercises = exercises
        self.muscleGroups = muscleGroups
        self.bodyMetrics = bodyMetrics
        self.onSeeAllExercises = onSeeAllExercises
        self.onACWRDetail = onACWRDetail
        self.onExerciseTapped = onExerciseTapped
        self.onBodyMetricsDetail = onBodyMetricsDetail
        self.onTrainingBalanceTapped = onTrainingBalanceTapped
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            StreakAndActivityView(streak: stats.streak, totals: totals)
            
            // Single ACWR for Volume (encompasses everything now)
            ACWRSummaryView(acwr: stats.volumeACWR, title: "Volume", onDetail: onACWRDetail)
            
            WeekStatsView(stats: stats)
            
            TrainingBalanceSummaryView(balanceData: balanceData, muscleGroups: muscleGroups, onDetail: onTrainingBalanceTapped)
            
            // Body metrics section (if available)
            if let metrics = bodyMetrics {
                BodyMetricsSummaryView(metrics: metrics, onDetail: onBodyMetricsDetail)
            }
            
            RecentExercisesView(
                exercises: recentExercises,
                onExerciseTapped: onExerciseTapped,
                onSeeAll: onSeeAllExercises
            )
        }
    }
}

// MARK: - Body Metrics Model
public struct BodyMetrics {
    public let currentWeight: Double  // kg
    public let height: Double         // cm
    public let weightHistory: [WeightEntry]
    
    public init(currentWeight: Double, height: Double, weightHistory: [WeightEntry]) {
        self.currentWeight = currentWeight
        self.height = height
        self.weightHistory = weightHistory
    }
    
    public var bmi: Double {
        let heightM = height / 100
        return currentWeight / (heightM * heightM)
    }
    
    public var bmiCategory: String {
        switch bmi {
        case ..<18.5: return "Underweight"
        case 18.5..<25: return "Normal"
        case 25..<30: return "Overweight"
        default: return "Obese"
        }
    }
    
    public var weekTrend: Double? {
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: .now)!
        
        guard let weekAgoWeight = weightHistory
            .filter({ $0.date >= weekAgo })
            .sorted(by: { $0.date < $1.date })
            .first?.weight else { return nil }
        
        return currentWeight - weekAgoWeight
    }
    
    public var formattedWeekTrend: String {
        guard let trend = weekTrend else { return "—" }
        let sign = trend >= 0 ? "+" : ""
        return String(format: "%@%.1f kg", sign, trend)
    }
}

public struct WeightEntry {
    public let date: Date
    public let weight: Double
    
    public init(date: Date, weight: Double) {
        self.date = date
        self.weight = weight
    }
}

// MARK: - BodyMetricsSummaryView
struct BodyMetricsSummaryView: View {
    let metrics: BodyMetrics
    let onDetail: () -> Void
    
    var body: some View {
        SectionContainer(title: "Body Metrics") {
            Button(action: onDetail) {
                VStack(spacing: 0) {
                    // Current weight and BMI row
                    HStack(spacing: 14) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Current Weight")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(String(format: "%.1f kg", metrics.currentWeight))
                                .font(.title2).fontWeight(.bold)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("BMI")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            HStack(spacing: 6) {
                                Text(String(format: "%.1f", metrics.bmi))
                                    .font(.title3).fontWeight(.semibold)
                                Text(metrics.bmiCategory)
                                    .font(.caption2).fontWeight(.medium)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 3)
                                    .background(bmiColor.opacity(0.12))
                                    .foregroundStyle(bmiColor)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                    .padding(16)
                    
                    Divider()
                        .padding(.horizontal, 16)
                    
                    // Trend and height row
                    HStack(spacing: 14) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("7-day trend")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            HStack(spacing: 4) {
                                Image(systemName: trendIcon)
                                    .font(.caption)
                                    .foregroundStyle(trendColor)
                                Text(metrics.formattedWeekTrend)
                                    .font(.subheadline).fontWeight(.medium)
                                    .foregroundStyle(trendColor)
                            }
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Height")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(String(format: "%.0f cm", metrics.height))
                                .font(.subheadline).fontWeight(.medium)
                        }
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                    .padding(16)
                }
            }
            .buttonStyle(.plain)
        }
    }
    
    private var bmiColor: Color {
        switch metrics.bmi {
        case ..<18.5: return .orange
        case 18.5..<25: return .green
        case 25..<30: return .orange
        default: return .red
        }
    }
    
    private var trendIcon: String {
        guard let trend = metrics.weekTrend else { return "minus" }
        if trend > 0.1 { return "arrow.up.right" }
        if trend < -0.1 { return "arrow.down.right" }
        return "arrow.right"
    }
    
    private var trendColor: Color {
        guard let trend = metrics.weekTrend else { return .secondary }
        if abs(trend) < 0.1 { return .secondary }
        return trend > 0 ? .orange : .blue
    }
}

// MARK: - Section container
// Wraps content in a clearly defined card with an optional header.
struct SectionContainer<Content: View>: View {
    let title: String?
    let headerTrailing: AnyView?
    let content: Content

    init(
        title: String? = nil,
        headerTrailing: AnyView? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.headerTrailing = headerTrailing
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let title {
                HStack {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)
                        .tracking(0.5)
                    Spacer()
                    headerTrailing
                }
                .padding(.bottom, 8)
                .padding(.horizontal, 2)
            }

            VStack(alignment: .leading, spacing: 0) {
                content
            }
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(.separator).opacity(0.4), lineWidth: 0.5)
            )
        }
    }
}

// MARK: - HomeStats
struct HomeStats {
    let totals: [DailyTotal]

    var streak: Int {
        let keys = Set(totals.map(\.id))
        var count = 0
        var checking = Date.now
        while true {
            let key = DateFormatter.yyyyMMdd.string(from: checking)
            if keys.contains(key) {
                count += 1
                checking = Calendar.current.date(byAdding: .day, value: -1, to: checking)!
            } else { break }
        }
        return count
    }

    private var last7Days: [DailyTotal] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let start = calendar.date(byAdding: .day, value: -6, to: today)! // today + 6 previous days

        return totals.filter { $0.date >= start }
    }

    var weekTotalSets: Int      { last7Days.reduce(0) { $0 + $1.totalSets } }
    var weekTotalReps: Int      { last7Days.reduce(0) { $0 + $1.totalReps } }
    var weekTotalVolume: Double { last7Days.reduce(0) { $0 + $1.totalVolume } }
    var weekActiveDays: Int     { last7Days.count }

    var formattedWeekVolume: String {
        weekTotalVolume >= 1000
            ? String(format: "%.1fk", weekTotalVolume / 1000)
            : String(format: "%.0f", weekTotalVolume)
    }

    var volumeACWR: ACWR {
        let fmt = DateFormatter.yyyyMMdd
        let volumeByKey = Dictionary(uniqueKeysWithValues: totals.map { ($0.id, $0.totalVolume) })
        func average(over days: Int) -> Double {
            let total = (0..<days).reduce(0) { sum, offset in
                let date = Calendar.current.date(byAdding: .day, value: -offset, to: .now)!
                return sum + (volumeByKey[fmt.string(from: date)] ?? 0)
            }
            return Double(total) / Double(days)
        }
        let acute = average(over: 7)
        let chronic = average(over: 28)
        guard chronic > 0 else { return ACWR(acute: acute, chronic: chronic, ratio: nil) }
        return ACWR(acute: acute, chronic: chronic, ratio: acute / chronic)
    }
}

// MARK: - ACWR model
public struct ACWR {
    public let acute: Double
    public let chronic: Double
    public let ratio: Double?

    public enum Zone {
        case optimal, caution, danger, low, insufficient

        public var color: Color {
            switch self {
            case .optimal:      return .green
            case .caution:      return .orange
            case .danger:       return .red
            case .low:          return .blue
            case .insufficient: return .secondary
            }
        }

        public var label: String {
            switch self {
            case .optimal:      return "Optimal"
            case .caution:      return "Caution"
            case .danger:       return "High risk"
            case .low:          return "Low load"
            case .insufficient: return "Not enough data"
            }
        }

        public var explanation: String {
            switch self {
            case .optimal:
                return "Your training load is well balanced against your baseline."
            case .caution:
                return "Recent load is elevated. Consider managing intensity."
            case .danger:
                return "Recent load significantly exceeds baseline. Risk of overtraining is elevated."
            case .low:
                return "Recent load is below baseline. Consider gradually increasing training."
            case .insufficient:
                return "Not enough training history. Keep logging to build your baseline."
            }
        }
    }

    public var zone: Zone {
        guard let r = ratio else { return .insufficient }
        switch r {
        case ..<0.8:    return .low
        case 0.8..<1.3: return .optimal
        case 1.3..<1.5: return .caution
        default:        return .danger
        }
    }

    public var formattedRatio: String {
        guard let r = ratio else { return "—" }
        return String(format: "%.2f", r)
    }
}

// MARK: - StreakAndActivityView
struct StreakAndActivityView: View {
    let streak: Int
    let totals: [DailyTotal]
    private let days = 30

    private var activeDateKeys: Set<String> { Set(totals.map(\.id)) }

    private var dayData: [String] {
        (0..<days).reversed().map { offset in
            let date = Calendar.current.date(byAdding: .day, value: -offset, to: .now)!
            return DateFormatter.yyyyMMdd.string(from: date)
        }
    }

    var body: some View {
        SectionContainer(title: "Activity") {
            // Streak row
            HStack(spacing: 12) {
                Text(streak > 0 ? "🔥" : "💤")
                    .font(.title2)
                VStack(alignment: .leading, spacing: 2) {
                    Text(streak > 0 ? "\(streak) day streak" : "No active streak")
                        .font(.headline)
                    Text(streak > 0 ? "Keep it going!" : "Log a workout to start one")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            .padding(16)

            Divider()
                .padding(.horizontal, 16)

            // Activity dots
            VStack(alignment: .leading, spacing: 10) {
                Text("Last 30 days")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                GeometryReader { geo in
                    let spacing: CGFloat = 3
                    let dotSize = (geo.size.width - spacing * CGFloat(days - 1)) / CGFloat(days)
                    HStack(spacing: spacing) {
                        ForEach(dayData, id: \.self) { key in
                            Circle()
                                .fill(activeDateKeys.contains(key)
                                      ? Color.green
                                      : Color(.tertiarySystemFill))
                                .frame(width: dotSize, height: dotSize)
                        }
                    }
                }
                .frame(height: 22)
            }
            .padding(16)
        }
    }
}

// MARK: - WeekStatsView
struct WeekStatsView: View {
    let stats: HomeStats

    var body: some View {
        SectionContainer(title: "Last 7 days") {
            LazyVGrid(
                columns: [GridItem(.flexible()), GridItem(.flexible())],
                spacing: 0
            ) {
                StatCell(label: "Sets",        value: "\(stats.weekTotalSets)",
                         icon: "square.stack.fill", color: .orange, borders: [.bottom, .trailing])
                StatCell(label: "Reps",        value: "\(stats.weekTotalReps)",
                         icon: "repeat",            color: .purple, borders: [.bottom])
                StatCell(label: "Volume",      value: stats.formattedWeekVolume,
                         icon: "chart.bar.fill",    color: .blue,   borders: [.trailing])
                StatCell(label: "Active days", value: "\(stats.weekActiveDays) / 7",
                         icon: "calendar",          color: .green,  borders: [])
            }
        }
    }
}

// MARK: - StatCell (grid cell inside a SectionContainer)
struct StatCell: View {
    let label: String
    let value: String
    let icon: String
    let color: Color
    let borders: Set<Edge>

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(color)
            Text(value)
                .font(.title2).fontWeight(.bold)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .overlay(alignment: .bottom) {
            if borders.contains(.bottom) {
                Rectangle()
                    .fill(Color(.separator).opacity(0.4))
                    .frame(height: 0.5)
            }
        }
        .overlay(alignment: .trailing) {
            if borders.contains(.trailing) {
                Rectangle()
                    .fill(Color(.separator).opacity(0.4))
                    .frame(width: 0.5)
            }
        }
    }
}

/// MARK: - ACWRSummaryView
struct ACWRSummaryView: View {
    let acwr: ACWR
    let title: String
    let onDetail: () -> Void

    var body: some View {
        SectionContainer(title: "Workload - \(title)") {
            Button(action: onDetail) {
                VStack(spacing: 16) {
                    // Top row — big number + zone badge
                    HStack(alignment: .firstTextBaseline, spacing: 10) {
                        Text(acwr.formattedRatio)
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundStyle(acwr.zone.color)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(acwr.zone.label)
                                .font(.caption2).fontWeight(.semibold)
                                .padding(.horizontal, 7)
                                .padding(.vertical, 3)
                                .background(acwr.zone.color.opacity(0.12))
                                .foregroundStyle(acwr.zone.color)
                                .clipShape(Capsule())
                            Text("ACWR")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .tracking(1)
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }

                    // Zone bar
                    ACWRZoneBar(acwr: acwr)

                    // Explanation
                    Text(acwr.zone.explanation)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(16)
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - ACWRZoneBar
struct ACWRZoneBar: View {
    let acwr: ACWR

    // Zone definitions — must sum to 1.0 in proportional width
    // Scale: 0.0 → 2.0, zones: 0–0.8, 0.8–1.3, 1.3–1.5, 1.5–2.0
    private struct Zone {
        let label: String
        let color: Color
        let proportion: CGFloat  // share of total bar width
        let maxValue: Double     // upper bound on the 0–2 scale
    }

    private let zones: [Zone] = [
        Zone(label: "Low",      color: .blue,   proportion: 0.40, maxValue: 0.8),
        Zone(label: "Optimal",  color: .green,  proportion: 0.25, maxValue: 1.3),
        Zone(label: "Caution",  color: .orange, proportion: 0.10, maxValue: 1.5),
        Zone(label: "High",     color: .red,    proportion: 0.25, maxValue: 2.0)
    ]

    private var clampedRatio: Double {
        guard let r = acwr.ratio else { return 1.0 }
        return min(max(r, 0.0), 2.0)
    }

    // Convert ratio value to fractional position (0→1) along the bar
    // accounting for non-uniform zone widths
    private func barPosition(for value: Double) -> CGFloat {
        let boundaries = [0.0, 0.8, 1.3, 1.5, 2.0]
        let proportions: [CGFloat] = [0.40, 0.25, 0.10, 0.25]

        for i in 0..<4 {
            let lo = boundaries[i]
            let hi = boundaries[i + 1]
            if value <= hi || i == 3 {
                let t = CGFloat((value - lo) / (hi - lo))
                let startProportion = proportions[0..<i].reduce(0, +)
                return startProportion + t * proportions[i]
            }
        }
        return 1.0
    }

    var body: some View {
        VStack(spacing: 6) {
            GeometryReader { geo in
                let barHeight: CGFloat = 10
                let markerSize: CGFloat = 16
                let totalHeight = markerSize + 4 + barHeight

                ZStack(alignment: .topLeading) {
                    // Coloured zone segments
                    HStack(spacing: 2) {
                        ForEach(Array(zones.enumerated()), id: \.offset) { index, zone in
                            RoundedRectangle(cornerRadius: 3)
                                .fill(zone.color.opacity(0.25))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 3)
                                        .stroke(zone.color.opacity(0.5), lineWidth: 1)
                                )
                                .frame(width: geo.size.width * zone.proportion - 2, height: barHeight)
                        }
                    }
                    .frame(height: barHeight)
                    .offset(y: markerSize + 4)

                    // Position marker (triangle + circle)
                    let markerX = barPosition(for: clampedRatio) * geo.size.width
                    VStack(spacing: 0) {
                        // Triangle pointer
                        Triangle()
                            .fill(acwr.zone.color)
                            .frame(width: 10, height: 6)

                        // Circle dot
                        Circle()
                            .fill(acwr.zone.color)
                            .frame(width: markerSize - 6, height: markerSize - 6)
                    }
                    .frame(width: markerSize)
                    .offset(x: markerX - markerSize / 2, y: 0)
                }
                .frame(height: totalHeight)
            }
            .frame(height: 34)

            // Zone labels
            HStack(spacing: 2) {
                ForEach(Array(zones.enumerated()), id: \.offset) { _, zone in
                    Text(zone.label)
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(zone.color)
                        .frame(maxWidth: .infinity)
                        .frame(width: nil)
                }
            }
        }
    }
}

// MARK: - Triangle shape (points downward)
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

// MARK: - TrainingBalanceSummaryView
struct TrainingBalanceSummaryView: View {
    let balanceData: TrainingBalanceData
    let muscleGroups: [MuscleGroup]
    let onDetail: () -> Void

    var body: some View {
        SectionContainer(title: "Training Balance") {
            Button(action: onDetail) {
                HStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.blue.opacity(0.12))
                            .frame(width: 50, height: 50)
                        Image(systemName: "chart.bar.fill")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(.blue)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            Text("Muscle Group Balance")
                                .font(.subheadline).fontWeight(.medium)
                                .foregroundStyle(.primary)
                            if let topGroup = balanceData.topMuscleGroups.first,
                               let name = muscleGroups.first(where: { $0.id == topGroup.muscleGroup })?.name {
                                Text(name)
                                    .font(.caption2).fontWeight(.semibold)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 3)
                                    .background(Color.blue.opacity(0.12))
                                    .foregroundStyle(.blue)
                                    .clipShape(Capsule())
                            }
                        }
                        Text(summaryMessage)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                .padding(16)
            }
            .buttonStyle(.plain)
        }
    }

    private var summaryMessage: String {
        let count = balanceData.topMuscleGroups.count
        guard count > 0 else { return "No training data for this period." }

        let topName = muscleGroups.first(where: { $0.id == balanceData.topMuscleGroups[0].muscleGroup })?.name ?? "Unknown"

        if count == 1 {
            return "Only \(topName) trained this period. Try adding more variety."
        }

        let topVolume = balanceData.topMuscleGroups[0].volume
        let secondVolume = balanceData.topMuscleGroups[1].volume
        let ratio = secondVolume > 0 ? topVolume / secondVolume : 0

        if ratio > 3 {
            return "\(topName) is dominating your volume. Consider balancing across more groups."
        } else if count >= 4 {
            return "Training \(count) muscle groups with good distribution."
        } else {
            return "Training \(count) muscle groups this period."
        }
    }
}

// MARK: - RecentExercisesView
struct RecentExercisesView: View {
    let exercises: [ExerciseStats]
    let onExerciseTapped: (ExerciseStats) -> Void
    let onSeeAll: () -> Void

    var body: some View {
        SectionContainer(
            title: "Recent exercises",
            headerTrailing: AnyView(
                Button("See all", action: onSeeAll)
                    .font(.subheadline)
                    .foregroundStyle(.orange)
            )
        ) {
            if exercises.isEmpty {
                Text("No exercises logged yet")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(16)
            } else {
                ForEach(Array(exercises.enumerated()), id: \.element.id) { index, exercise in
                    Button(action: { onExerciseTapped(exercise) }) {
                        ExerciseRowContent(exercise: exercise)
                    }
                    .buttonStyle(.plain)

                    if index < exercises.count - 1 {
                        Divider()
                            .padding(.horizontal, 16)
                    }
                }
            }
        }
    }
}

// MARK: - ExerciseRowContent (inner content, used in both home and list)
struct ExerciseRowContent: View {
    let exercise: ExerciseStats

    var body: some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text(exercise.exerciseName)
                    .font(.subheadline).fontWeight(.medium)
                    .foregroundStyle(.primary)
                Text(relativeDate)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text(primaryStat)
                    .font(.subheadline).fontWeight(.semibold)
                    .foregroundStyle(.primary)
                Text(primaryStatLabel)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Image(systemName: "chevron.right")
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private var relativeDate: String {
        let f = RelativeDateTimeFormatter()
        f.unitsStyle = .abbreviated
        return f.localizedString(for: exercise.lastRecordDate, relativeTo: .now)
    }

    private var primaryStat: String {
        if exercise.isTimeBased {
            let m = exercise.maxTime / 60
            let s = exercise.maxTime % 60
            return String(format: "%d:%02d", m, s)
        } else if exercise.maxWeight > 0 {
            return "\(Int(exercise.maxWeight))kg"
        } else {
            return "\(exercise.totalReps) reps"
        }
    }

    private var primaryStatLabel: String {
        if exercise.isTimeBased   { return "best time" }
        if exercise.maxWeight > 0 { return "max weight" }
        return "total reps"
    }
}

// MARK: - Shared StatCard (for use outside home screen if needed)
public struct StatCard: View {
    let label: String
    let value: String
    let icon: String
    let color: Color

    public init(label: String, value: String, icon: String, color: Color) {
        self.label = label
        self.value = value
        self.icon = icon
        self.color = color
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(color)
            Spacer()
            Text(value)
                .font(.title2).fontWeight(.bold)
                .minimumScaleFactor(0.5)
                .lineLimit(2)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .frame(height: 110)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color(.separator).opacity(0.4), lineWidth: 0.5)
        )
    }
}

// MARK: - Preview
#Preview {
    let totals = MockDailyTotalsProvider().previewTotals
    let bodyMetrics = BodyMetrics(
        currentWeight: 82.5,
        height: 180,
        weightHistory: [
            WeightEntry(date: Calendar.current.date(byAdding: .day, value: -7, to: .now)!, weight: 81.8),
            WeightEntry(date: Calendar.current.date(byAdding: .day, value: -3, to: .now)!, weight: 82.1),
            WeightEntry(date: .now, weight: 82.5)
        ]
    )
    ScrollView {
        HomeScreenContent(
            totals: totals,
            exercises: ExerciseStats.mocks,
            muscleGroups: [],
            bodyMetrics: bodyMetrics,
            onSeeAllExercises: {},
            onACWRDetail: {},
            onExerciseTapped: { _ in },
            onBodyMetricsDetail: {},
            onTrainingBalanceTapped: {}
        )
        .padding()
    }
}
