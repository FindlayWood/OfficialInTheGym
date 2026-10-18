//
//  WelcomeWeeklyBarsIllustration.swift
//  LoginKit
//
//  Created by Findlay Wood on 18/10/2026.
//

import SwiftUI

/// The STATS tab's weekly chart, small: `darkColor` bars with opacity carrying size, the ramp the
/// real `TrainingChartSection` uses. The intro grows them from the baseline; after that each scene
/// rolls the chart forward a week — a new bar grows in on the right as the oldest leaves on the left.
struct WelcomeWeeklyBarsIllustration: View {

    let isRevealed: Bool
    var scene: Int = 0

    /// Fixed and looping: a rising shape with a lighter week now and then — a shape, not anybody's
    /// training. Eight are shown at a time.
    private static let pattern: [CGFloat] = [0.35, 0.5, 0.45, 0.65, 0.4, 0.75, 0.85, 1.0, 0.6, 0.8, 0.7, 0.9]
    private static let visible = 8

    var body: some View {
        HStack(alignment: .bottom, spacing: 4) {
            // Identified by absolute week, so a scene inserts one bar and removes one rather than
            // re-heighting all eight.
            ForEach(scene..<(scene + Self.visible), id: \.self) { week in
                let height = Self.pattern[week % Self.pattern.count]
                RoundedRectangle(cornerRadius: 3, style: .continuous)
                    .fill(Color.darkColor.opacity(0.3 + 0.7 * height))
                    .frame(width: 7, height: 56 * (isRevealed ? height : 0.04))
                    .animation(
                        .spring(response: 0.45, dampingFraction: 0.8).delay(Double(week - scene) * 0.06),
                        value: isRevealed
                    )
                    .transition(
                        .asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        )
                    )
            }
        }
        .frame(width: 88, height: 56, alignment: .bottom)
        .clipped()
    }
}

#Preview {
    WelcomeWeeklyBarsIllustration(isRevealed: true)
}
