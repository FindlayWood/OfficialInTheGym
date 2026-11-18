//
//  ProfileWorkoutChoiceCard.swift
//  ProfileKit
//
//  Created by Findlay Wood on 12/11/2026.
//

import SwiftUI

/// The choice a tap on your own public workout offers: MyDay's page, where it can be added to today
/// or scheduled, or DISCOVER's, where people rate and comment on it.
///
/// **A centred card, not a system action sheet**, on the shape of MyDay's
/// `WorkoutSessionDialogOverlay`: an action sheet brings system chrome that reads as another app.
/// Cancel is quiet text; the dim behind it dismisses too (`ProfileWorkoutChoiceModifier`).
struct ProfileWorkoutChoiceCard: View {
    let title: String
    let onOpenWorkout: () -> Void
    let onViewOnDiscover: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Text(title.isEmpty ? "Untitled workout" : title)
                .font(.system(size: 17, weight: .semibold))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .padding(.top, 4)

            option(
                systemImage: "dumbbell.fill",
                title: "Open workout",
                subtitle: "Add to Today or schedule it",
                action: onOpenWorkout
            )
            option(
                systemImage: "magnifyingglass",
                title: "View on DISCOVER",
                subtitle: "Ratings and comments",
                action: onViewOnDiscover
            )

            Button(action: onCancel) {
                Text("Cancel")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.secondary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
    }

    private func option(systemImage: String, title: String, subtitle: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: systemImage)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.white)
                    .frame(width: 36, height: 36)
                    .background(Color.darkColor, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.primary)
                    Text(subtitle)
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                }
                Spacer(minLength: 0)
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color(.tertiarySystemBackground))
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
