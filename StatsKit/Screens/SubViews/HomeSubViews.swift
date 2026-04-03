//
//  HomeSubViews.swift
//  StatsKit
//
//  Created by Findlay Wood on 22/03/2026.
//

import SwiftUI

import SwiftUI

// MARK: - HomeScreenContent
public struct HomeScreenContent: View {
    let totals: [DailyTotal]
    let exercises: [ExerciseStats]
    let onSeeAllExercises: () -> Void
    let onACWRDetail: () -> Void
    let onExerciseTapped: (ExerciseStats) -> Void

    private var stats: HomeStats { HomeStats(totals: totals) }

    private var recentExercises: [ExerciseStats] {
        Array(exercises
            .sorted { $0.lastRecordDate > $1.lastRecordDate }
            .prefix(3))
    }

    public init(
        totals: [DailyTotal],
        exercises: [ExerciseStats],
        onSeeAllExercises: @escaping () -> Void,
        onACWRDetail: @escaping () -> Void,
        onExerciseTapped: @escaping (ExerciseStats) -> Void
    ) {
        self.totals = totals
        self.exercises = exercises
        self.onSeeAllExercises = onSeeAllExercises
        self.onACWRDetail = onACWRDetail
        self.onExerciseTapped = onExerciseTapped
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            StreakAndActivityView(streak: stats.streak, totals: totals)
            WeekStatsView(stats: stats)
            ACWRSummaryView(acwr: stats.acwr, title: "Reps", onDetail: onACWRDetail)
            if stats.volumeACWR.ratio != nil {
                ACWRSummaryView(acwr: stats.volumeACWR, title: "Volume", onDetail: onACWRDetail)
            }
            if stats.weightACWR.ratio != nil {
                ACWRSummaryView(acwr: stats.weightACWR, title: "Weight", onDetail: onACWRDetail)
            }
            if stats.timeACWR.ratio != nil {
                ACWRSummaryView(acwr: stats.timeACWR, title: "Time", onDetail: onACWRDetail)
            }
            RecentExercisesView(
                exercises: recentExercises,
                onExerciseTapped: onExerciseTapped,
                onSeeAll: onSeeAllExercises
            )
        }
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
            ? String(format: "%.1fk kg", weekTotalVolume / 1000)
            : "\(Int(weekTotalVolume)) kg"
    }

    var acwr: ACWR {
        let fmt = DateFormatter.yyyyMMdd
        let repsByKey = Dictionary(uniqueKeysWithValues: totals.map { ($0.id, $0.totalReps) })
        func average(over days: Int) -> Double {
            let total = (0..<days).reduce(0) { sum, offset in
                let date = Calendar.current.date(byAdding: .day, value: -offset, to: .now)!
                return sum + (repsByKey[fmt.string(from: date)] ?? 0)
            }
            return Double(total) / Double(days)
        }
        let acute = average(over: 7)
        let chronic = average(over: 28)
        guard chronic > 0 else { return ACWR(acute: acute, chronic: chronic, ratio: nil) }
        return ACWR(acute: acute, chronic: chronic, ratio: acute / chronic)
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
    
    var weightACWR: ACWR {
        let fmt = DateFormatter.yyyyMMdd
        let weightByKey = Dictionary(uniqueKeysWithValues: totals.map { ($0.id, $0.totalWeight) })
        func average(over days: Int) -> Double {
            let total = (0..<days).reduce(0) { sum, offset in
                let date = Calendar.current.date(byAdding: .day, value: -offset, to: .now)!
                return sum + (weightByKey[fmt.string(from: date)] ?? 0)
            }
            return Double(total) / Double(days)
        }
        let acute = average(over: 7)
        let chronic = average(over: 28)
        guard chronic > 0 else { return ACWR(acute: acute, chronic: chronic, ratio: nil) }
        return ACWR(acute: acute, chronic: chronic, ratio: acute / chronic)
    }
    
    var timeACWR: ACWR {
        let fmt = DateFormatter.yyyyMMdd
        let timeByKey = Dictionary(uniqueKeysWithValues: totals.map { ($0.id, $0.totalTime) })
        func average(over days: Int) -> Double {
            let total = (0..<days).reduce(0) { sum, offset in
                let date = Calendar.current.date(byAdding: .day, value: -offset, to: .now)!
                return sum + (timeByKey[fmt.string(from: date)] ?? 0)
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
                return "Your recent training load is well balanced against your longer term workload."
            case .caution:
                return "Your recent load is creeping above your baseline. Consider managing intensity."
            case .danger:
                return "Your recent load significantly exceeds your baseline. Risk of overtraining is elevated."
            case .low:
                return "Your recent load is below your baseline. Consider gradually increasing training."
            case .insufficient:
                return "Not enough training history to calculate a meaningful ratio. Keep logging."
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
                                      ? Color.orange
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

// MARK: - ACWRSummaryView
struct ACWRSummaryView: View {
    let acwr: ACWR
    let title: String
    let onDetail: () -> Void

    var body: some View {
        SectionContainer(title: "Workload - \(title)") {
            Button(action: onDetail) {
                HStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(acwr.zone.color.opacity(0.12))
                            .frame(width: 50, height: 50)
                        Text(acwr.formattedRatio)
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundStyle(acwr.zone.color)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            Text("Workload ratio (ACWR)")
                                .font(.subheadline).fontWeight(.medium)
                                .foregroundStyle(.primary)
                            Text(acwr.zone.label)
                                .font(.caption2).fontWeight(.semibold)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .background(acwr.zone.color.opacity(0.12))
                                .foregroundStyle(acwr.zone.color)
                                .clipShape(Capsule())
                        }
                        Text(acwr.zone.explanation)
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
    ScrollView {
        HomeScreenContent(
            totals: totals,
            exercises: ExerciseStats.mocks,
            onSeeAllExercises: {},
            onACWRDetail: {},
            onExerciseTapped: { _ in }
        )
        .padding()
    }
}
