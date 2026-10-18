//
//  WelcomeReadinessIllustration.swift
//  LoginKit
//
//  Created by Findlay Wood on 18/10/2026.
//

import SwiftUI

/// The weekly fatigue check, small: a ring filling to the latest jump as a share of the recent
/// best, the percentage counting up beside it. `darkColor` rather than the zone colours, which
/// LoginKit does not carry — a seventh copy of the matte palette for one ring is not worth it.
struct WelcomeReadinessIllustration: View {

    let isRevealed: Bool

    private let reading = 97

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color(UIColor.tertiarySystemFill), lineWidth: 6)
            Circle()
                .trim(from: 0, to: isRevealed ? CGFloat(reading) / 100 : 0)
                .stroke(Color.darkColor, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 0.9).delay(0.2), value: isRevealed)

            VStack(spacing: 0) {
                Text("\(isRevealed ? reading : 0)%")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color.primary)
                    .contentTransition(.numericText(value: Double(isRevealed ? reading : 0)))
                    .animation(.easeOut(duration: 0.9).delay(0.2), value: isRevealed)
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
