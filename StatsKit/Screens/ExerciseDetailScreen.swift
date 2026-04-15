//
//  ExerciseDetailScreen.swift
//  StatsKit
//
//  Created by Findlay Wood on 22/03/2026.
//

internal import Charts
import SwiftUI

// MARK: - ExerciseDetailScreen
struct ExerciseDetailScreen: View {
    @ObservedObject var viewModel: ExerciseDetailViewModel

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.dailyStats.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        AllTimeStatsSection(exercise: viewModel.exercise)
                        MaxStatsSection(exercise: viewModel.exercise)
                        
                        if !viewModel.dailyStats.isEmpty {
                            RepsOverTimeSection(dailyStats: viewModel.dailyStats)
                            ACWRChartsSection(
                                dailyStats: viewModel.dailyStats,
                                exercise: viewModel.exercise
                            )
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                .refreshable { await viewModel.load() }
            }
        }
        .background { Color.black.opacity(0.3).ignoresSafeArea() }
        .navigationTitle(viewModel.exercise.exerciseName)
        .navigationBarTitleDisplayMode(.large)
        .task { await viewModel.load() }
        .alert("Could not load data", isPresented: .constant(viewModel.error != nil)) {
            Button("Retry") { Task { await viewModel.load() } }
            Button("Dismiss", role: .cancel) { viewModel.error = nil }
        } message: {
            Text(viewModel.error?.localizedDescription ?? "")
        }
    }
}

// MARK: - All time stats
private struct AllTimeStatsSection: View {
    let exercise: ExerciseStats

    var body: some View {
        SectionContainer(title: "All time") {
            LazyVGrid(
                columns: [GridItem(.flexible()), GridItem(.flexible())],
                spacing: 0
            ) {
                StatCell(
                    label: "Total sets",
                    value: "\(exercise.setCount)",
                    icon: "square.stack.fill",
                    color: .orange,
                    borders: [.bottom, .trailing]
                )
                StatCell(
                    label: exercise.isTimeBased ? "Total time" : "Total reps",
                    value: exercise.isTimeBased
                        ? formatTime(exercise.totalTime)
                        : "\(exercise.totalReps)",
                    icon: exercise.isTimeBased ? "clock.fill" : "repeat",
                    color: .purple,
                    borders: [.bottom]
                )
                StatCell(
                    label: "Avg reps/set",
                    value: !exercise.isTimeBased && exercise.setCount > 0
                        ? "\(exercise.totalReps / exercise.setCount)"
                        : "—",
                    icon: "chart.bar.fill",
                    color: .blue,
                    borders: [.trailing]
                )
                StatCell(
                    label: "Since",
                    value: exercise.firstRecordDate.formatted(.dateTime.month(.abbreviated).year()),
                    icon: "calendar",
                    color: .green,
                    borders: []
                )
            }
        }
    }
}

// MARK: - Personal bests
private struct MaxStatsSection: View {
    let exercise: ExerciseStats

    var body: some View {
        SectionContainer(title: "Personal bests") {
            LazyVGrid(
                columns: [GridItem(.flexible()), GridItem(.flexible())],
                spacing: 0
            ) {
                if exercise.isTimeBased {
                    StatCell(
                        label: "Best time",
                        value: formatTime(exercise.maxTime),
                        icon: "stopwatch.fill",
                        color: .yellow,
                        borders: []
                    )
                } else if exercise.maxWeight > 0 {
                    StatCell(
                        label: "Max weight",
                        value: "\(Int(exercise.maxWeight))kg",
                        icon: "scalemass.fill",
                        color: .yellow,
                        borders: [.trailing]
                    )
                    StatCell(
                        label: "Best volume day",
                        value: formatVolume(exercise.totalVolume),
                        icon: "star.fill",
                        color: .yellow,
                        borders: []
                    )
                } else {
                    StatCell(
                        label: "Most reps (set)",
                        value: exercise.setCount > 0
                            ? "\(exercise.totalReps / max(exercise.setCount, 1))"
                            : "—",
                        icon: "star.fill",
                        color: .yellow,
                        borders: [.trailing]
                    )
                    StatCell(
                        label: "Total sets logged",
                        value: "\(exercise.setCount)",
                        icon: "square.stack.fill",
                        color: .yellow,
                        borders: []
                    )
                }
            }
        }
    }
}

// MARK: - RepsOverTimeSection
struct RepsOverTimeSection: View {
    let dailyStats: [ExerciseDailyStats]

    private var weeklyData: (values: [Double], labels: [String]) {
        let weeks = buildWeeks(from: dailyStats).suffix(10)
        return (
            values: weeks.map { Double($0.totalReps) },
            labels: weeks.map(\.label)
        )
    }

    var body: some View {
        let data = weeklyData
        guard !data.values.isEmpty else { return AnyView(EmptyView()) }

        return AnyView(
            MiniBarChart(
                title: "Reps per week",
                values: data.values,
                labels: data.labels,
                color: .purple,
                formatValue: { "\(Int($0))" }
            )
        )
    }
}

// MARK: - Simplified ACWRChartsSection (volume only)
struct ACWRChartsSection: View {
    let dailyStats: [ExerciseDailyStats]
    let exercise: ExerciseStats

    private var acwrPoints: [ACWRPoint] {
        let weeks = buildWeeks(from: dailyStats)

        return weeks.enumerated().map { weekIndex, week in
            guard weekIndex >= 3 else {
                return ACWRPoint(id: weekIndex, label: week.label,
                                 reps: nil, weight: nil, volume: nil, time: nil)
            }

            let chronic = Array(weeks[(weekIndex - 3)..<weekIndex])
            let chronicAvg = chronic.map(\.volume).reduce(0.0, +) / 3.0
            let ratio: Double? = chronicAvg > 0 ? week.volume / chronicAvg : nil

            return ACWRPoint(
                id: weekIndex,
                label: week.label,
                reps: nil,
                weight: nil,
                volume: ratio,
                time: nil
            )
        }
    }

    private var hasEnoughData: Bool {
        acwrPoints.dropFirst(3).contains { $0.volume != nil }
    }

    var body: some View {
        SectionContainer(title: "Workload ratio · last 90 days") {
            VStack(spacing: 0) {
                if !hasEnoughData {
                    Text("Not enough training history to calculate workload ratio")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(32)
                } else {
                    // Zone legend
                    HStack(spacing: 12) {
                        ForEach([
                            ("Low", Color.blue),
                            ("Optimal", Color.green),
                            ("Caution", Color.orange),
                            ("High risk", Color.red)
                        ], id: \.0) { label, color in
                            HStack(spacing: 4) {
                                Circle().fill(color).frame(width: 7, height: 7)
                                Text(label).font(.system(size: 9)).foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 14)
                    .padding(.bottom, 4)

                    ACWRMiniChart(
                        title: "Volume ACWR",
                        values: acwrPoints.map(\.volume),
                        labels: acwrPoints.map(\.label)
                    )

                    Divider().padding(.horizontal, 16)

                    Text("Acute = 7 days · Chronic = prior 3 weeks avg")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(14)
                }
            }
        }
    }
}

// MARK: - Helpers
private func formatTime(_ secs: Int) -> String {
    let h = secs / 3600
    let m = (secs % 3600) / 60
    let s = secs % 60
    return h > 0
        ? String(format: "%d:%02d:%02d", h, m, s)
        : String(format: "%d:%02d", m, s)
}

private func formatVolume(_ v: Double) -> String {
    guard v > 0 else { return "—" }
    return v >= 1000 ? String(format: "%.1fk", v / 1000) : "\(Int(v))"
}

// MARK: - Preview
#Preview {
    NavigationStack {
        ExerciseDetailScreen(
            viewModel: ExerciseDetailViewModel(
                exercise: ExerciseStats.mocks.first!,
                provider: MockExerciseDailyStatsProvider()
            )
        )
    }
}

import Combine

// MARK: - ExerciseDetailViewModel
final class ExerciseDetailViewModel: ObservableObject {
    @Published public var dailyStats: [ExerciseDailyStats] = []
    @Published public var isLoading = false
    @Published public var error: Error?
 
    let exercise: ExerciseStats
    let provider: ExerciseDailyStatsProviding
 
    init(exercise: ExerciseStats, provider: ExerciseDailyStatsProviding) {
        self.exercise = exercise
        self.provider = provider
    }
 
    func load() async {
        isLoading = true
        error = nil
        do {
            // Load 90 days once — all periods and ACWR derived client-side
            dailyStats = try await provider.fetchDailyStats(
                exerciseID: exercise.exerciseID,
                from: DetailRange.threeMonths.cutoffDate
            )
        } catch {
            self.error = error
        }
        isLoading = false
    }
 
    var allPeriodStats: [PeriodStats] {
        DetailRange.allCases.map { PeriodStats.compute(from: dailyStats, range: $0) }
    }
 
    var metricACWR: MetricACWR {
        MetricACWR.compute(from: dailyStats)
    }
    
    var filteredStats: [ExerciseDailyStats] {
        let calendar = Calendar.current
        let now = Date()
        guard let startDate = calendar.date(byAdding: .day, value: -90, to: now) else {
            return []
        }

        return dailyStats
            .filter { $0.date >= startDate }
            .sorted { $0.date < $1.date }
    }
    
    var weeklyStats: [WeeklyStat] {
        let calendar = Calendar.current

        let grouped = Dictionary(grouping: filteredStats) { stat in
            calendar.dateInterval(of: .weekOfYear, for: stat.date)?.start ?? stat.date
        }

        return grouped.map { (weekStart, stats) in
            let total = stats.reduce(0) { $0 + $1.totalVolume }
            return WeeklyStat(week: weekStart, volume: total)
        }
        .sorted { $0.week < $1.week }
    }
}
