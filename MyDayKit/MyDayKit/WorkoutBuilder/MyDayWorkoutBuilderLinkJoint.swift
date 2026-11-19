//
//  MyDayWorkoutBuilderLinkJoint.swift
//  MyDayKit
//
//  Created by Findlay Wood on 18/11/2026.
//

import SwiftUI

/// What sits between two exercise cards in the builder: the button that makes them a superset.
///
/// **Apart**, it is a gap holding a small "Superset" capsule on the page. **Linked**, the gap
/// closes to a narrow strip and a filled link bridges it, overlapping both cards; tapping it
/// splits them again. The change is one spring, so the cards visibly pull together and apart.
/// The cards keep their rounded corners throughout (see `MyDayWorkoutBuilderExerciseCard`).
///
/// The linked badge overhangs the gap into both cards, so the stack must give the joint a higher
/// `zIndex` than its cards, or the card below draws over half of it and takes its taps.
struct MyDayWorkoutBuilderLinkJoint: View {

    let isLinked: Bool
    let onToggle: () -> Void

    static let openHeight: CGFloat = 48
    static let linkedHeight: CGFloat = 8

    var body: some View {
        ZStack {
            if isLinked {
                linkedBadge
                    .transition(.scale(scale: 0.4).combined(with: .opacity))
            } else {
                linkButton
                    .transition(.scale(scale: 0.8).combined(with: .opacity))
            }
        }
        .frame(height: isLinked ? Self.linkedHeight : Self.openHeight)
        .frame(maxWidth: .infinity)
        .sensoryFeedback(.impact(weight: .medium), trigger: isLinked)
    }

    private var linkedBadge: some View {
        Button(action: onToggle) {
            Image(systemName: "link")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 32, height: 32)
                .background(Color.darkColor, in: Circle())
                // A ring of the page colour, so the badge reads as sitting in the gap rather than
                // as a hole in either card.
                .overlay(Circle().strokeBorder(Color.pageColor, lineWidth: 3))
                .frame(width: 44, height: 44)
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Split superset")
    }

    private var linkButton: some View {
        Button(action: onToggle) {
            HStack(spacing: 6) {
                Image(systemName: "link")
                    .font(.system(size: 11, weight: .bold))
                Text("Superset")
                    .font(.system(size: 12, weight: .semibold))
            }
            .foregroundStyle(Color.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.white.opacity(0.16), in: Capsule())
            .frame(height: 44)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Superset with the next exercise")
    }
}
