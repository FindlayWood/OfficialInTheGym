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
/// closes, the two cards meet at a seam (they square off the corners they share, see
/// `MyDayWorkoutBuilderExerciseCard`) and a filled link sits on the seam; tapping it splits them
/// again. The change is one spring, so the cards visibly pull together and apart.
///
/// The linked badge overhangs the seam into both cards, so the stack must give the joint a higher
/// `zIndex` than its cards, or the card below draws over half of it and takes its taps.
struct MyDayWorkoutBuilderLinkJoint: View {

    let isLinked: Bool
    let onToggle: () -> Void

    static let openHeight: CGFloat = 48

    var body: some View {
        ZStack {
            if isLinked {
                seam
                linkedBadge
                    .transition(.scale(scale: 0.4).combined(with: .opacity))
            } else {
                linkButton
                    .transition(.scale(scale: 0.8).combined(with: .opacity))
            }
        }
        .frame(height: isLinked ? 1 : Self.openHeight)
        .frame(maxWidth: .infinity)
        .sensoryFeedback(.impact(weight: .medium), trigger: isLinked)
    }

    /// The divider a joined card draws between its halves, on the cards' own surface so the
    /// seam does not show the page through it.
    private var seam: some View {
        Color(UIColor.secondarySystemGroupedBackground)
            .overlay(Divider().padding(.horizontal, 16))
    }

    private var linkedBadge: some View {
        Button(action: onToggle) {
            Image(systemName: "link")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 32, height: 32)
                .background(Color.darkColor, in: Circle())
                .overlay(
                    Circle().strokeBorder(Color(UIColor.secondarySystemGroupedBackground), lineWidth: 3)
                )
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
