//
//  TrainingBalanceScreen.swift
//  StatsKit
//
//  Created by Findlay Wood on 13/04/2026.
//

import SwiftUI

// MARK: - TrainingBalanceScreen
public struct TrainingBalanceScreen: View {
    let totals: [DailyTotal]
    let muscleGroups: [MuscleGroup]
    let movementPatterns: [MovementPattern]
    @State private var selectedRange: BalanceRange = .month
    @State private var selectedView: BalanceView = .muscleGroups
    
    private var balanceData: TrainingBalanceData {
        TrainingBalanceData(totals: totals, range: selectedRange, muscleGroups: muscleGroups)
    }
    
    public init(totals: [DailyTotal], muscleGroups: [MuscleGroup], movementPatterns: [MovementPattern]) {
        self.totals = totals
        self.muscleGroups = muscleGroups
        self.movementPatterns = movementPatterns
    }
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // View toggle
                Picker("View", selection: $selectedView) {
                    Text("Muscle Groups").tag(BalanceView.muscleGroups)
                    Text("Movement Patterns").tag(BalanceView.movements)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)
                
                // Range picker
                Picker("Range", selection: $selectedRange) {
                    ForEach(BalanceRange.allCases) { range in
                        Text(range.label).tag(range)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)
                
                // Summary card
                if selectedView == .muscleGroups {
                    MuscleGroupSummaryCard(data: balanceData)
                } else {
                    MovementPatternSummaryCard(data: balanceData)
                }
                
                // Volume breakdown
                if selectedView == .muscleGroups {
                    MuscleGroupBreakdown(data: balanceData, muscleGroups: muscleGroups)
                    
                    // Progression charts for top 3 muscle groups
                    ForEach(balanceData.topMuscleGroups.prefix(3), id: \.muscleGroup) { item in
                        MuscleGroupProgressionChart(
                            muscleGroup: item.muscleGroup,
                            muscleGroupName: muscleGroups.first(where: { $0.id == item.muscleGroup })?.name ?? item.muscleGroup,
                            totals: totals,
                            range: selectedRange
                        )
                    }
                } else {
                    MovementPatternBreakdown(data: balanceData)
                    
                    // Progression charts for top 3 movement patterns
                    ForEach(balanceData.topMovementPatterns.prefix(3), id: \.pattern) { item in
                        MovementPatternProgressionChart(
                            pattern: item.pattern,
                            totals: totals,
                            range: selectedRange
                        )
                    }
                }
                
                // Balance insights
                if selectedView == .muscleGroups {
                    MuscleBalanceInsights(data: balanceData, muscleGroups: muscleGroups)
                } else {
                    MovementBalanceInsights(data: balanceData)
                }
            }
            .padding(.vertical, 20)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("Training Balance")
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Supporting Types
enum BalanceView {
    case muscleGroups
    case movements
}

enum BalanceRange: String, CaseIterable, Identifiable {
    case week = "1W"
    case twoWeeks = "2W"
    case month = "1M"
    
    var id: String { rawValue }
    var label: String { rawValue }
    
    var days: Int {
        switch self {
        case .week: return 7
        case .twoWeeks: return 14
        case .month: return 30
        }
    }
}

// MARK: - TrainingBalanceData
struct TrainingBalanceData {
    let totals: [DailyTotal]
    let range: BalanceRange
    let muscleGroups: [MuscleGroup]
    
    private var filteredTotals: [DailyTotal] {
        let cutoff = Calendar.current.date(byAdding: .day, value: -range.days, to: .now)!
        return totals.filter { $0.date >= cutoff }
    }
    
    var summary: DailyTotalSummary {
        DailyTotalSummary.from(filteredTotals)
    }
    
    var topMuscleGroups: [(muscleGroup: String, volume: Double)] {
        summary.muscleGroupVolumes
            .sorted { $0.value > $1.value }
            .map { ($0.key, $0.value) }
    }
    
    var topMovementPatterns: [(pattern: String, volume: Double)] {
        summary.movementTypeVolumes
            .sorted { $0.value > $1.value }
            .map { ($0.key, $0.value) }
    }
    
    var totalVolume: Double {
        summary.totalVolume
    }
    
    // Push/Pull ratio
    var pushPullRatio: Double? {
        let pushVolume = summary.movementTypeVolumes.filter { isPushMovement($0.key) }.values.reduce(0, +)
        let pullVolume = summary.movementTypeVolumes.filter { isPullMovement($0.key) }.values.reduce(0, +)
        
        guard pullVolume > 0 else { return nil }
        return pushVolume / pullVolume
    }
    
    // Check if movement is push
    private func isPushMovement(_ movement: String) -> Bool {
        movement.lowercased().contains("push") || movement.lowercased().contains("press")
    }
    
    // Check if movement is pull
    private func isPullMovement(_ movement: String) -> Bool {
        movement.lowercased().contains("pull") || movement.lowercased().contains("row")
    }
    
    // Muscle group imbalances
    func imbalanceFor(muscle1: String, muscle2: String) -> Double? {
        guard let vol1 = summary.muscleGroupVolumes[muscle1],
              let vol2 = summary.muscleGroupVolumes[muscle2],
              vol2 > 0 else { return nil }
        return vol1 / vol2
    }
}

// MARK: - MuscleGroupSummaryCard
struct MuscleGroupSummaryCard: View {
    let data: TrainingBalanceData
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Most Trained")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    if let top = data.topMuscleGroups.first {
                        
                        let muscleGroup = data.muscleGroups.first(where: { $0.id == top.muscleGroup })
                        Text(muscleGroup?.name ?? top.muscleGroup)
                            .font(.title2).fontWeight(.bold)
                            .onAppear {
                                print(top.muscleGroup)
                            }
                    } else {
                        Text("—")
                            .font(.title2).fontWeight(.bold)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Muscle Groups")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(data.summary.muscleGroupVolumes.count)")
                        .font(.title2).fontWeight(.bold)
                }
            }
            
            Divider()
            
            // Top 3 muscle groups
            VStack(spacing: 8) {
                ForEach(Array(data.topMuscleGroups.prefix(3).enumerated()), id: \.offset) { index, item in
                    let muscleGroup = data.muscleGroups.first(where: { $0.id == item.muscleGroup })
                    HStack {
                        HStack(spacing: 8) {
                            Text("\(index + 1)")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(.secondary)
                                .frame(width: 20)
                            
                            Circle()
                                .fill(.blue)
                                .frame(width: 10, height: 10)
                            
                            Text(muscleGroup?.name ?? item.muscleGroup)
                                .font(.subheadline)
                        }
                        
                        Spacer()
                        
                        Text(formatVolume(item.volume))
                            .font(.subheadline).fontWeight(.medium)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.separator).opacity(0.4), lineWidth: 0.5)
        )
        .padding(.horizontal, 16)
        .onAppear {
            print("balance data ---- \(data.muscleGroups)")
        }
    }
    
    private func formatVolume(_ volume: Double) -> String {
        volume >= 1000 ? String(format: "%.1fk", volume / 1000) : String(format: "%.0f", volume)
    }
}

// MARK: - MovementPatternSummaryCard
struct MovementPatternSummaryCard: View {
    let data: TrainingBalanceData
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Most Common")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    if let top = data.topMovementPatterns.first {
                        Text(formatMovementName(top.pattern))
                            .font(.title2).fontWeight(.bold)
                    } else {
                        Text("—")
                            .font(.title2).fontWeight(.bold)
                    }
                }
                
                Spacer()
                
                if let ratio = data.pushPullRatio {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Push:Pull")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        HStack(spacing: 4) {
                            Text(String(format: "%.1f:1", ratio))
                                .font(.title3).fontWeight(.semibold)
                            Image(systemName: ratioIcon(ratio))
                                .font(.caption)
                                .foregroundStyle(ratioColor(ratio))
                        }
                    }
                }
            }
            
            Divider()
            
            // Top movement patterns
            VStack(spacing: 8) {
                ForEach(Array(data.topMovementPatterns.prefix(5).enumerated()), id: \.offset) { index, item in
                    HStack {
                        HStack(spacing: 8) {
                            Text("\(index + 1)")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(.secondary)
                                .frame(width: 20)
                            
                            Text(formatMovementName(item.pattern))
                                .font(.subheadline)
                        }
                        
                        Spacer()
                        
                        Text(formatVolume(item.volume))
                            .font(.subheadline).fontWeight(.medium)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.separator).opacity(0.4), lineWidth: 0.5)
        )
        .padding(.horizontal, 16)
    }
    
    private func formatMovementName(_ name: String) -> String {
        name.replacingOccurrences(of: "_", with: " ").capitalized
    }
    
    private func formatVolume(_ volume: Double) -> String {
        volume >= 1000 ? String(format: "%.1fk", volume / 1000) : String(format: "%.0f", volume)
    }
    
    private func ratioIcon(_ ratio: Double) -> String {
        if ratio > 1.3 { return "arrow.up.circle.fill" }
        if ratio < 0.7 { return "arrow.down.circle.fill" }
        return "checkmark.circle.fill"
    }
    
    private func ratioColor(_ ratio: Double) -> Color {
        if ratio > 1.3 || ratio < 0.7 { return .orange }
        return .green
    }
}

// MARK: - MuscleGroupBreakdown
struct MuscleGroupBreakdown: View {
    let data: TrainingBalanceData
    let muscleGroups: [MuscleGroup]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Volume Distribution")
                .font(.caption).fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .textCase(.uppercase).tracking(0.5)
            
            VStack(spacing: 8) {
                ForEach(data.topMuscleGroups, id: \.muscleGroup) { item in
                    let muscleGroup = muscleGroups.first(where: { $0.id == item.muscleGroup })
                    let percentage = data.totalVolume > 0 ? item.volume / data.totalVolume : 0
                    
                    MuscleGroupBar(
                        name: muscleGroup?.name ?? item.muscleGroup,
                        volume: item.volume,
                        percentage: percentage,
                        color: .blue
                    )
                }
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

struct MuscleGroupBar: View {
    let name: String
    let volume: Double
    let percentage: Double
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                HStack(spacing: 6) {
                    Circle()
                        .fill(color)
                        .frame(width: 8, height: 8)
                    Text(name)
                        .font(.subheadline).fontWeight(.medium)
                }
                
                Spacer()
                
                Text(formatVolume(volume))
                    .font(.caption).fontWeight(.medium)
                    .foregroundStyle(.secondary)
            }
            
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
        }
    }
    
    private func formatVolume(_ volume: Double) -> String {
        volume >= 1000 ? String(format: "%.1fk", volume / 1000) : String(format: "%.0f", volume)
    }
}

// MARK: - MovementPatternBreakdown
struct MovementPatternBreakdown: View {
    let data: TrainingBalanceData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Pattern Distribution")
                .font(.caption).fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .textCase(.uppercase).tracking(0.5)
            
            VStack(spacing: 8) {
                ForEach(data.topMovementPatterns, id: \.pattern) { item in
                    let percentage = data.totalVolume > 0 ? item.volume / data.totalVolume : 0
                    
                    MovementPatternBar(
                        name: formatMovementName(item.pattern),
                        volume: item.volume,
                        percentage: percentage,
                        color: colorForMovement(item.pattern)
                    )
                }
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
    
    private func formatMovementName(_ name: String) -> String {
        name.replacingOccurrences(of: "_", with: " ").capitalized
    }
    
    private func colorForMovement(_ movement: String) -> Color {
        let lower = movement.lowercased()
        if lower.contains("push") || lower.contains("press") { return .orange }
        if lower.contains("pull") || lower.contains("row") { return .blue }
        if lower.contains("squat") || lower.contains("lunge") { return .purple }
        if lower.contains("hinge") { return .green }
        return .gray
    }
}

struct MovementPatternBar: View {
    let name: String
    let volume: Double
    let percentage: Double
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(name)
                    .font(.subheadline).fontWeight(.medium)
                
                Spacer()
                
                Text(formatVolume(volume))
                    .font(.caption).fontWeight(.medium)
                    .foregroundStyle(.secondary)
            }
            
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
        }
    }
    
    private func formatVolume(_ volume: Double) -> String {
        volume >= 1000 ? String(format: "%.1fk", volume / 1000) : String(format: "%.0f", volume)
    }
}

// MARK: - MuscleGroupProgressionChart
struct MuscleGroupProgressionChart: View {
    let muscleGroup: String
    let muscleGroupName: String
    let totals: [DailyTotal]
    let range: BalanceRange
    
    private var values: [Double] {
        let fmt = DateFormatter.yyyyMMdd
        let rangeEnd = Date.now
        let rangeStart = Calendar.current.date(byAdding: .day, value: -range.days, to: rangeEnd)!
        
        return (0..<range.days).map { offset in
            let date = Calendar.current.date(byAdding: .day, value: offset, to: rangeStart)!
            let key = fmt.string(from: date)
            
            guard let total = totals.first(where: { $0.id == key }) else { return 0 }
            return total.muscleGroupVolumes[muscleGroup] ?? 0
        }
    }
    
    private var labels: [String] {
        let rangeEnd = Date.now
        let rangeStart = Calendar.current.date(byAdding: .day, value: -range.days, to: rangeEnd)!
        
        return (0..<range.days).map { offset in
            let date = Calendar.current.date(byAdding: .day, value: offset, to: rangeStart)!
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            return formatter.string(from: date)
        }
    }
    
    var body: some View {
        MiniLineChart(
            title: muscleGroupName,
            values: values,
            labels: labels,
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
        .padding(.horizontal, 16)
    }
}

// MARK: - MovementPatternProgressionChart
struct MovementPatternProgressionChart: View {
    let pattern: String
    let totals: [DailyTotal]
    let range: BalanceRange
    
    private var values: [Double] {
        let fmt = DateFormatter.yyyyMMdd
        let rangeEnd = Date.now
        let rangeStart = Calendar.current.date(byAdding: .day, value: -range.days, to: rangeEnd)!
        
        return (0..<range.days).map { offset in
            let date = Calendar.current.date(byAdding: .day, value: offset, to: rangeStart)!
            let key = fmt.string(from: date)
            
            guard let total = totals.first(where: { $0.id == key }) else { return 0 }
            return total.movementTypeVolumes[pattern] ?? 0
        }
    }
    
    private var labels: [String] {
        let rangeEnd = Date.now
        let rangeStart = Calendar.current.date(byAdding: .day, value: -range.days, to: rangeEnd)!
        
        return (0..<range.days).map { offset in
            let date = Calendar.current.date(byAdding: .day, value: offset, to: rangeStart)!
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            return formatter.string(from: date)
        }
    }
    
    var body: some View {
        MiniLineChart(
            title: pattern.replacingOccurrences(of: "_", with: " ").capitalized,
            values: values,
            labels: labels,
            color: colorForMovement(pattern),
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
        .padding(.horizontal, 16)
    }
    
    private func colorForMovement(_ movement: String) -> Color {
        let lower = movement.lowercased()
        if lower.contains("push") || lower.contains("press") { return .orange }
        if lower.contains("pull") || lower.contains("row") { return .blue }
        if lower.contains("squat") || lower.contains("lunge") { return .purple }
        if lower.contains("hinge") { return .green }
        return .gray
    }
}

// MARK: - Balance Insights
struct MuscleBalanceInsights: View {
    let data: TrainingBalanceData
    let muscleGroups: [MuscleGroup]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Balance Insights")
                .font(.caption).fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .textCase(.uppercase).tracking(0.5)
            
            VStack(spacing: 8) {
                // Check for imbalances
                if let topMuscle = data.topMuscleGroups.first,
                   let bottomMuscle = data.topMuscleGroups.last,
                   topMuscle.volume > bottomMuscle.volume * 3 {
                    let topName = muscleGroups.first(where: { $0.id == topMuscle.muscleGroup })?.name ?? topMuscle.muscleGroup
                    let bottomName = muscleGroups.first(where: { $0.id == bottomMuscle.muscleGroup })?.name ?? bottomMuscle.muscleGroup
                    
                    InsightCard(
                        icon: "exclamationmark.triangle.fill",
                        color: .orange,
                        title: "Volume Imbalance",
                        message: "\(topName) volume is significantly higher than \(bottomName). Consider balancing your training."
                    )
                }
                
                // Praise well-rounded training
                if data.topMuscleGroups.count >= 4 {
                    let topVolume = data.topMuscleGroups.first?.volume ?? 0
                    let fourthVolume = data.topMuscleGroups.dropFirst(3).first?.volume ?? 0
                    
                    if topVolume > 0 && fourthVolume / topVolume > 0.5 {
                        InsightCard(
                            icon: "checkmark.circle.fill",
                            color: .green,
                            title: "Well-Rounded Training",
                            message: "You're training multiple muscle groups with good balance. Keep it up!"
                        )
                    }
                }
                
                // Suggest neglected areas
                if data.topMuscleGroups.count >= 5 {
                    let bottomTwo = data.topMuscleGroups.suffix(2)
                    let names = bottomTwo.compactMap { item in
                        muscleGroups.first(where: { $0.id == item.muscleGroup })?.name ?? item.muscleGroup
                    }
                    
                    if !names.isEmpty {
                        InsightCard(
                            icon: "lightbulb.fill",
                            color: .blue,
                            title: "Consider Adding",
                            message: "Your \(names.joined(separator: " and ")) could use more volume this period."
                        )
                    }
                }
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

struct MovementBalanceInsights: View {
    let data: TrainingBalanceData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Pattern Insights")
                .font(.caption).fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .textCase(.uppercase).tracking(0.5)
            
            VStack(spacing: 8) {
                // Push/Pull ratio
                if let ratio = data.pushPullRatio {
                    if ratio > 1.3 {
                        InsightCard(
                            icon: "arrow.up.circle.fill",
                            color: .orange,
                            title: "Push Dominant",
                            message: String(format: "Push:Pull ratio is %.1f:1. Consider adding more pulling movements for balance.", ratio)
                        )
                    } else if ratio < 0.7 {
                        InsightCard(
                            icon: "arrow.down.circle.fill",
                            color: .orange,
                            title: "Pull Dominant",
                            message: String(format: "Push:Pull ratio is %.1f:1. Consider adding more pushing movements for balance.", ratio)
                        )
                    } else {
                        InsightCard(
                            icon: "checkmark.circle.fill",
                            color: .green,
                            title: "Balanced Push/Pull",
                            message: String(format: "Your Push:Pull ratio of %.1f:1 is well balanced.", ratio)
                        )
                    }
                }
                
                // Pattern diversity
                if data.topMovementPatterns.count >= 4 {
                    InsightCard(
                        icon: "star.fill",
                        color: .purple,
                        title: "Great Variety",
                        message: "You're using \(data.topMovementPatterns.count) different movement patterns. This promotes well-rounded development."
                    )
                }
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

struct InsightCard: View {
    let icon: String
    let color: Color
    let title: String
    let message: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline).fontWeight(.medium)
                Text(message)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(12)
        .background(color.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// Reuse MiniLineChart from ACWRDetailScreen
// (copy the implementation or import from shared file)

// MARK: - Preview
#Preview {
    NavigationStack {
        TrainingBalanceScreen(
            totals: MockDailyTotalsProvider().previewTotals,
            muscleGroups: [
                MuscleGroup(id: "chest", name: "Chest"),
                MuscleGroup(id: "back", name: "Back"),
                MuscleGroup(id: "legs", name: "Legs"),
                MuscleGroup(id: "shoulders", name: "Shoulders")
            ],
            movementPatterns: [
                MovementPattern(id: "push", name: "Push"),
                MovementPattern(id: "pull", name: "Pull"),
                MovementPattern(id: "squat", name: "Squat")
            ]
        )
    }
}
