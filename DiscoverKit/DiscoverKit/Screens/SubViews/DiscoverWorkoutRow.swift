//
//  DiscoverWorkoutRow.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 28/09/2026.
//

import SwiftUI

/// A public workout wherever DISCOVER lists one — home, see-all, tags and
/// search, so a workout reads the same in all four.
///
/// **Taller than the exercise row, and without its icon tile.** Every workout
/// drew the same dumbbell, so the tile said nothing and spent 56pt saying it.
/// The space went to what tells two workouts apart: who made it, when, how many
/// exercises, how it is rated and talked about, and its tags. The builder's
/// name suggestions make repeated titles common (several "Saturday Upper"), so
/// the title alone was never enough.
///
/// The byline comes from `DiscoverAuthorDirectory`, requested as the row
/// appears, and is simply absent until it resolves. Rating and comments only
/// show once there are some — "no ratings" on every new workout is noise.
struct DiscoverWorkoutRow: View {
    let card: DiscoverWorkoutCard
    @ObservedObject var authors: DiscoverAuthorDirectory

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(card.title.isEmpty ? "Untitled workout" : card.title)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    if let byline {
                        Text(byline)
                            .font(.system(size: 13))
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
                HStack(spacing: 6) {
                    DiscoverMetaPill(systemImage: "list.bullet", text: exerciseCount)
                    if let average = card.ratingSummary.average {
                        DiscoverMetaPill(
                            systemImage: "star.fill",
                            text: String(format: "%.1f", average) + " (\(card.ratingSummary.count))"
                        )
                    }
                    if let comments = card.commentCount, comments > 0 {
                        DiscoverMetaPill(systemImage: "bubble.left", text: "\(comments)")
                    }
                }
                if let tags = card.visibleTags, !tags.isEmpty {
                    Text(tags.prefix(3).map { "#\($0)" }.joined(separator: "  "))
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color.darkColor)
                        .lineLimit(1)
                }
            }
            Spacer(minLength: 0)
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.tertiary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .contentShape(Rectangle())
        .onAppear { authors.request(card.createdBy) }
    }

    private var exerciseCount: String {
        card.exerciseCount == 1 ? "1 exercise" : "\(card.exerciseCount) exercises"
    }

    /// "by Alex Morgan · 3 Sep", the date alone until the name resolves, and
    /// nothing at all for a template with neither.
    private var byline: String? {
        let date = card.createdAt?.formatted(.dateTime.day().month(.abbreviated))
        let name = authors.name(for: card.createdBy).map { "by \($0)" }
        let parts = [name, date].compactMap { $0 }
        return parts.isEmpty ? nil : parts.joined(separator: " · ")
    }
}
