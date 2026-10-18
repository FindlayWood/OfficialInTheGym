//
//  WelcomeReadinessIllustration.swift
//  LoginKit
//
//  Created by Findlay Wood on 18/10/2026.
//

import SwiftUI

/// The weekly fatigue check, small: a ring filling to the latest jump as a share of the recent
/// best, the percentage beside it. The intro fills it; each scene is another week's check, the
/// ring moving to the new reading and the number ticking to it. `darkColor` rather than the zone
/// colours, which LoginKit does not carry — a seventh copy of the matte palette for one ring is not
/// worth it.
///
/// Every reading stays at or above 95%, PerformanceKit's `FatigueZone.fresh` boundary, so the
/// caption is always true. A sample that wandered into "Caution" would be selling worry.
struct WelcomeReadinessIllustration: View {

    let isRevealed: Bool
    var scene: Int = 0

    private static let readings = [97, 95, 98, 96]

    var body: some View {
        let reading = isRevealed ? Self.readings[scene % Self.readings.count] : 0
        ZStack {
            Circle()
                .stroke(Color(UIColor.tertiarySystemFill), lineWidth: 6)
            Circle()
                .trim(from: 0, to: CGFloat(reading) / 100)
                .stroke(Color.darkColor, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(scene == 0 ? .easeOut(duration: 0.9).delay(0.2) : .easeInOut(duration: 0.6), value: reading)

            VStack(spacing: 0) {
                Text("\(reading)%")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color.primary)
                    .contentTransition(.numericText(value: Double(reading)))
                    .animation(scene == 0 ? .easeOut(duration: 0.9).delay(0.2) : .easeInOut(duration: 0.6), value: reading)
                Text("Fresh")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(Color.secondary)
            }
        }
        .frame(width: 58, height: 58)
    }
}

#Preview {
    WelcomeReadinessIllustration(isRevealed: true)
}
