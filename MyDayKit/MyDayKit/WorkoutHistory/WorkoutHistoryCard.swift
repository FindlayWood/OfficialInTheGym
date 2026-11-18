//
//  WorkoutHistoryCard.swift
//  MyDayKit
//
//  Created by Findlay Wood on 18/11/2026.
//

import SwiftUI

/// "Your history" at the top of the workout page: times done, average time, average RPE, and when
/// it was last done.
///
/// **Three cells, never a chart.** It sits above the exercises the user came to read, so it has to
/// be a glance. Trends over time are STATS' job.
///
/// **The card keeps its height in every state** — loading draws the same cells dimmed, and the
/// empty and failed states are one line in the same card — so the exercises below never jump when
/// the read lands.
struct WorkoutHistoryCard: View {

    @ObservedObject var viewModel: WorkoutHistoryViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your history")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.secondary)
                .textCase(.uppercase)
                .tracking(0.8)

            content
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .task { await viewModel.load() }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading:
            cells(timesDone: "0", averageTime: "—", averageRPE: "—")
                .redacted(reason: .placeholder)
        case .failed:
            message("Couldn't load your history. It will try again next time you open this workout.")
        case .loaded(let summary) where summary.timesDone == 0:
            message("Not done yet. Once you finish it, your time and RPE show here.")
        case .loaded(let summary):
            VStack(alignment: .leading, spacing: 10) {
                cells(
                    timesDone: "\(summary.timesDone)",
                    averageTime: summary.averageDurationSeconds.map(Self.formatDuration) ?? "—",
                    averageRPE: summary.averageRPE.map { String(format: "%.1f", $0) } ?? "—"
                )
                if let lastDone = summary.lastDone {
                    Text("Last done \(Self.formatLastDone(lastDone))")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color.secondary)
                }
            }
        }
    }

    private func cells(timesDone: String, averageTime: String, averageRPE: String) -> some View {
        HStack(spacing: 10) {
            cell(title: "Done", value: timesDone)
            cell(title: "Avg time", value: averageTime)
            cell(title: "Avg RPE", value: averageRPE)
        }
    }

    private func cell(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(Color.secondary)
                .textCase(.uppercase)
                .tracking(1.2)
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(Color.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color(UIColor.tertiarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func message(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 14))
            .foregroundStyle(Color.secondary)
            .fixedSize(horizontal: false, vertical: true)
    }

    // MARK: - Formatting

    /// Whole minutes, since a workout is timed in minutes: "48 min", "1h 05m". Under a minute reads
    /// "1 min" rather than "0 min", which would look like nothing was recorded. **Keep in step with
    /// DiscoverKit's `DiscoverWorkoutCommunitySection.formatDuration`**, the community half.
    static func formatDuration(_ seconds: Int) -> String {
        let minutes = max(1, Int((Double(seconds) / 60).rounded()))
        guard minutes >= 60 else { return "\(minutes) min" }
        return String(format: "%dh %02dm", minutes / 60, minutes % 60)
    }

    /// "today", "yesterday", else the day: "Tue 12 Nov". In the device's calendar, as MyDay's strip
    /// judges a day.
    static func formatLastDone(_ date: Date, now: Date = .now, calendar: Calendar = .current) -> String {
        if calendar.isDate(date, inSameDayAs: now) { return "today" }
        if let yesterday = calendar.date(byAdding: .day, value: -1, to: now),
           calendar.isDate(date, inSameDayAs: yesterday) {
            return "yesterday"
        }
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.timeZone = calendar.timeZone
        formatter.setLocalizedDateFormatFromTemplate("EEE d MMM")
        return formatter.string(from: date)
    }
}

#Preview {
    ZStack {
        Color.pageColor.ignoresSafeArea()
        WorkoutHistoryCard(
            viewModel: WorkoutHistoryViewModel(templateId: "preview", loader: PreviewWorkoutHistoryLoader())
        )
        .padding(16)
    }
}
