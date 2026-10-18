//
//  WelcomeCardPulse.swift
//  LoginKit
//
//  Created by Findlay Wood on 18/10/2026.
//

import SwiftUI

/// One pulse of light on the welcome card whose turn it is: the outline and a soft glow swell in
/// with the miniature's build, peak as it finishes, and ease out over the hold, gone before the
/// next card begins. The card lifts slightly with it.
///
/// **A pulse, not a light running round the edge.** The running light was tried twice: an angular
/// gradient sped up and slowed down along a wide card, and a steady trim still ran at its own lap
/// length, so the turn always ended with it part-way round — it "stopped at the bottom" and jumped
/// to the next card. A pulse starts and ends at nothing, so every turn ends cleanly; it has no
/// direction to pull the eye away from the miniature, and it brightens as the miniature fills, so
/// the two read as one event. **One pulse per turn, never a breathing loop**, which would read as
/// loading.
///
/// Keyed on the card's `scene`, which goes up once per turn, so the pulse is in step with the
/// rebuild (`WelcomeRebuilding`) by construction. With Reduce Motion the scene never changes and
/// there is no pulse.
struct WelcomeCardPulse: ViewModifier {

    let trigger: Int
    var cornerRadius: CGFloat = 16

    func body(content: Content) -> some View {
        content.keyframeAnimator(initialValue: 0.0, trigger: trigger) { card, glow in
            card
                .overlay {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .strokeBorder(Color.darkColor.opacity(0.6 * glow), lineWidth: 1.5)
                }
                .background {
                    // `darkColor` is the lighter brand blue in dark mode, so the glow shows on black.
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(Color(UIColor.secondarySystemBackground))
                        .shadow(color: Color.darkColor.opacity(0.35 * glow), radius: 12 * glow)
                }
                .scaleEffect(1 + 0.01 * glow)
        } keyframes: { _ in
            KeyframeTrack(\.self) {
                // Swells in as the miniature starts building (it waits a beat empty first)…
                CubicKeyframe(0.85, duration: 0.6)
                // …reaches its peak as the build lands…
                LinearKeyframe(1.0, duration: 0.7)
                // …and eases out over the hold, done before the next turn starts.
                CubicKeyframe(0.0, duration: 1.6)
            }
        }
    }
}

extension View {
    func welcomeCardPulse(trigger: Int) -> some View {
        modifier(WelcomeCardPulse(trigger: trigger))
    }
}
