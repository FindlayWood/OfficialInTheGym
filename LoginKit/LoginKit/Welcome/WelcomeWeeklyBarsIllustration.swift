//
//  WelcomeWeeklyBarsIllustration.swift
//  LoginKit
//
//  Created by Findlay Wood on 18/10/2026.
//

import SwiftUI

/// The STATS tab's weekly chart, small: `darkColor` bars with opacity carrying size, the ramp the
/// real `TrainingChartSection` uses. Building grows them from the baseline, oldest week first — an
/// empty chart filling in as training adds up.
struct WelcomeWeeklyBarsIllustration: View {

    let isBuilt: Bool

    /// Fixed, rising with one lighter week — a shape, not anybody's training.
    private let heights: [CGFloat] = [0.35, 0.5, 0.45, 0.65, 0.4, 0.75, 0.85, 1.0]

    var body: some View {
        HStack(alignment: .bottom, spacing: 4) {
            ForEach(Array(heights.enumerated()), id: \.offset) { index, height in
                RoundedRectangle(cornerRadius: 3, style: .continuous)
                    .fill(Color.darkColor.opacity(0.3 + 0.7 * height))
                    .frame(width: 7, height: 56 * (isBuilt ? height : 0.04))
                    .animation(
                        isBuilt
                            ? .spring(response: 0.45, dampingFraction: 0.8).delay(Double(index) * 0.09)
                            : .easeOut(duration: 0.2),
                        value: isBuilt
                    )
            }
        }
        .frame(height: 56, alignment: .bottom)
    }
}

#Preview {
    WelcomeWeeklyBarsIllustration(isBuilt: true)
}
