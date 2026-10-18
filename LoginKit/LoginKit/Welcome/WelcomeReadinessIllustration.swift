//
//  WelcomeReadinessIllustration.swift
//  LoginKit
//
//  Created by Findlay Wood on 18/10/2026.
//

import SwiftUI

/// The weekly fatigue check, small: a ring filling to the latest jump as a share of the recent
/// best, with the percentage counting up from 0 beside it. `darkColor` rather than the zone
/// colours, which LoginKit does not carry — a seventh copy of the matte palette for one ring is not
/// worth it.
///
/// The reading sits above 95%, PerformanceKit's `FatigueZone.fresh` boundary, so "Fresh" is true.
struct WelcomeReadinessIllustration: View {

    let isBuilt: Bool

    private let reading: Double = 96

    var body: some View {
        let value = isBuilt ? reading : 0
        // Clearing is instant: animated, the count ran back down from 96 to 0 before building up
        // again, which read as the reading dropping rather than a fresh start.
        let animation: Animation? = isBuilt ? .easeOut(duration: 1.1) : nil

        ZStack {
            Circle()
                .stroke(Color(UIColor.tertiarySystemFill), lineWidth: 6)
            Circle()
                .trim(from: 0, to: value / 100)
                .stroke(Color.darkColor, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(animation, value: isBuilt)

            VStack(spacing: 0) {
                WelcomeCountingText(value: value, suffix: "%")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color.primary)
                    .animation(animation, value: isBuilt)
                Text("Fresh")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(Color.secondary)
            }
        }
        .frame(width: 58, height: 58)
    }
}

#Preview {
    WelcomeReadinessIllustration(isBuilt: true)
}
