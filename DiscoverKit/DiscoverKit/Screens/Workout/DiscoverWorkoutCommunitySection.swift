//
//  DiscoverWorkoutCommunitySection.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 18/11/2026.
//

import SwiftUI

/// "How it goes": how many people have done the workout, their average time and RPE, under the
/// header where someone deciding whether to save it is looking.
///
/// **Not drawn at all until three people have done it** — no empty state. An empty card on most
/// workouts would say nothing but "nobody has", which is not a reason to save one.
///
/// Three cells, the same shape as MyDay's "Your history" card (`WorkoutHistoryCard`), so the two
/// read as the community and personal halves of one idea. The time format is that card's too —
/// **keep `formatDuration` in step with `WorkoutHistoryCard.formatDuration`**, a copy across the
/// module boundary like the colour extensions.
struct DiscoverWorkoutCommunitySection: View {

    @ObservedObject var viewModel: DiscoverWorkoutCommunityViewModel

    var body: some View {
        if let community = viewModel.shown {
            SectionContainer(title: "How it goes") {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 10) {
                        cell(title: "People", value: "\(community.peopleCount)")
                        cell(
                            title: "Avg time",
                            value: community.averageDurationSeconds.map(Self.formatDuration) ?? "—"
                        )
                        cell(
                            title: "Avg RPE",
                            value: community.averageRPE.map { String(format: "%.1f", $0) } ?? "—"
                        )
                    }
                    Text(Self.footnote(community))
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.secondary)
                }
                .padding(16)
            }
        }
    }

    private func cell(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .tracking(1.2)
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color(UIColor.tertiarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    // MARK: - Formatting

    /// "41 sessions by 14 people". People are never one here — the section needs three.
    static func footnote(_ community: DiscoverWorkoutCommunity) -> String {
        let sessions = community.sessionCount == 1 ? "1 session" : "\(community.sessionCount) sessions"
        return "\(sessions) by \(community.peopleCount) people"
    }

    /// Whole minutes: "48 min", "1h 05m", and "1 min" rather than "0 min" under a minute.
    static func formatDuration(_ seconds: Int) -> String {
        let minutes = max(1, Int((Double(seconds) / 60).rounded()))
        guard minutes >= 60 else { return "\(minutes) min" }
        return String(format: "%dh %02dm", minutes / 60, minutes % 60)
    }
}
