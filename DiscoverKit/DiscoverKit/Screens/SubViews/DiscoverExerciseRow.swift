//
//  DiscoverExerciseRow.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 28/09/2026.
//

import SwiftUI

/// An exercise in a list: tile, name, and its category.
struct DiscoverExerciseRow: View {
    let card: DiscoverExerciseCard

    var body: some View {
        HStack(spacing: 12) {
            DiscoverIconTile(systemName: "figure.strengthtraining.traditional")
            VStack(alignment: .leading, spacing: 3) {
                Text(card.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                if let category = card.categoryDisplayName {
                    Text(category)
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
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
}
