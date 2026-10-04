//
//  ProfileHighlightsSection.swift
//  ProfileKit
//
//  Created by Findlay Wood on 04/10/2026.
//

import SwiftUI

/// The PB tiles: up to three side by side, each the best as the big number
/// over the exercise name. Equal widths, so the eye reads them as a set of
/// peers rather than a ranked list.
///
/// On your own profile the header carries Edit, and an empty section says how
/// it fills. On someone else's, an empty section is not drawn at all: an empty
/// box on another person's profile says nothing about them.
struct ProfileHighlightsSection: View {

    let highlights: ProfileHighlights?
    var onEdit: (() -> Void)?

    var body: some View {
        if let onEdit {
            section(onEdit: onEdit)
        } else if let highlights, !highlights.highlights.isEmpty {
            section(onEdit: nil)
        }
    }

    private func section(onEdit: (() -> Void)?) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(highlights?.isPinned == true ? "Highlights" : "Top Lifts")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.secondary)
                    .textCase(.uppercase)
                    .tracking(0.8)
                Spacer()
                if let onEdit {
                    Button("Edit", action: onEdit)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.darkColor)
                }
            }
            .padding(.horizontal, 4)

            if let tiles = highlights?.highlights, !tiles.isEmpty {
                HStack(spacing: 10) {
                    ForEach(tiles) { highlight in
                        tile(highlight)
                    }
                }
            } else {
                Text("Log some sets and your most-trained exercises show here, or choose your own with Edit.")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color(.secondarySystemBackground))
                    )
            }
        }
    }

    private func tile(_ highlight: ProfileHighlight) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(systemName: highlight.isTimeBased ? "timer" : "dumbbell.fill")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.darkColor)
            Text(highlight.valueText)
                .font(.system(size: 20, weight: .bold).monospacedDigit())
                .foregroundStyle(Color.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(highlight.exerciseName.isEmpty ? "Exercise" : highlight.exerciseName)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color.secondary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, minHeight: 104, alignment: .topLeading)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
        .accessibilityElement(children: .combine)
    }
}
