//
//  DiscoverWorkoutRow.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 28/09/2026.
//

import SwiftUI

/// A workout in a list: tile, title, and "N exercises · date" — the shape the
/// workout library's rows use, so a workout reads the same wherever it is
/// listed. The date separates same-named workouts, which the builder's name
/// suggestions make common.
struct DiscoverWorkoutRow: View {
    let card: DiscoverWorkoutCard

    var body: some View {
        HStack(spacing: 12) {
            DiscoverIconTile(systemName: "dumbbell.fill")
            VStack(alignment: .leading, spacing: 3) {
                Text(card.title.isEmpty ? "Untitled workout" : card.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                Text(subtitle)
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Spacer(minLength: 0)
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.tertiary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }

    private var subtitle: String {
        let count = card.exerciseCount == 1 ? "1 exercise" : "\(card.exerciseCount) exercises"
        guard let createdAt = card.createdAt else { return count }
        return count + " · " + createdAt.formatted(.dateTime.day().month(.abbreviated))
    }
}
