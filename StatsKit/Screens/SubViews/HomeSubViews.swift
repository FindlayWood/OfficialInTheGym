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
    let onACWRDetail: (TrainingLoadMetric) -> Void
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
        onACWRDetail: @escaping (TrainingLoadMetric) -> Void,
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
            // The chart leads. It is populated from the first logged set, where
            // both ACWR ratios need 28 days of history before they say anything
            // and session load needs a Cloud Function that has not shipped —
            // leading with those put the emptiest content in the most prominent
            // slot, and pushed everything concrete below the fold.
            TrainingChartSection(totals: totals)

            StreakAndActivityView(streak: stats.streak, totals: totals)

            // Both metrics in one card — see `TrainingLoadMetric` for why they
            // stay two ratios rather than being merged into one number.
            TrainingLoadSummaryView(stats: stats, onDetail: onACWRDetail)

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
                        .foregroundStyle(.white)
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

    /// What "now" means. Injectable so the date-dependent stats — the streak
    /// especially — can be asserted against a fixed day rather than whatever
    /// day the test suite happens to run on.
    var asOf: Date = .now

    /// Consecutive days trained, counting back from today.
    ///
    /// **Today is allowed to be pending.** A user thirty days into a streak who
    /// has not trained yet this morning still has a thirty-day streak — it only
    /// ends once today has become yesterday and is still empty. Requiring a
    /// logged today read "No active streak" to everyone every morning, which is
    /// both wrong and the opposite of the nudge the card exists to give.
    var streak: Int {
        let keys = Set(totals.map(\.id))
        var offset = keys.contains(StatsDay.key(for: asOf)) ? 0 : 1
        var count = 0
        while keys.contains(StatsDay.key(daysAgo: offset, from: asOf)) {
            count += 1
            offset += 1
        }
        return count
    }

    // The week's sets, reps, volume and active-day count used to be derived
    // here for a 2×2 grid. `TrainingChartSection` plots the first three over
    // twelve weeks and `ActivityGrid` draws the fourth as its rightmost column,
    // so a single week of each was the same data with none of the shape.

    func acwr(_ metric: TrainingLoadMetric) -> ACWR {
        ACWR.rolling(loadByDay: totals.loadByDay(metric), endingOn: asOf)
    }
}

// MARK: - StreakAndActivityView
struct StreakAndActivityView: View {
    let streak: Int
    let totals: [DailyTotal]

    var body: some View {
        SectionContainer(title: "Activity · last 4 weeks") {
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

            // The "N / 7 days this week" readout that briefly sat in the row
            // above is gone: the grid's rightmost column *is* this week, so the
            // figure restated what the card already draws.
            ActivityGrid(totals: totals)
                .padding(16)
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

// MARK: - RecentExercisesView
struct RecentExercisesView: View {
    let exercises: [ExerciseStats]
    let onExerciseTapped: (ExerciseStats) -> Void
    let onSeeAll: () -> Void

    var body: some View {
        SectionContainer(
            title: "Recent exercises",
            // **A `SectionContainer` header sits on the page background, which
            // is `Color.darkColor` — not on the card.** That is why the title is
            // white. This was `.orange` (an accent used nowhere else), then
            // briefly `darkColor`, which is the background colour: the button
            // was still there and still tappable, but invisible. It is a filled
            // capsule now rather than bare text, so it reads as the button it is.
            headerTrailing: AnyView(
                Button(action: onSeeAll) {
                    HStack(spacing: 3) {
                        Text("View all")
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10, weight: .semibold))
                    }
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.white.opacity(0.18))
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
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
            // A solid 44pt tile, the same anchor the workout library rows use
            // and for the same reason: at this size a 12%-tinted wash barely
            // registers and the rows had nothing holding the eye down the list.
            // `ExerciseStats` carries no category, so the glyph is the one
            // distinction the model does make — timed work against loaded.
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.darkColor)
                    .frame(width: 44, height: 44)

                Image(systemName: exercise.isTimeBased ? "timer" : "dumbbell.fill")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
            }

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
            onACWRDetail: { _ in },
            onExerciseTapped: { _ in },
            onBodyMetricsDetail: {},
            onTrainingBalanceTapped: {}
        )
        .padding()
    }
}
