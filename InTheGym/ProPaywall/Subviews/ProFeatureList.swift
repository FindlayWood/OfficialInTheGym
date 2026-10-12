//
//  ProFeatureList.swift
//  InTheGym
//
//  Created by Findlay Wood on 09/08/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import SwiftUI

/// What pro includes — each line a thing the user can do, not the name of a screen.
///
/// **Only what pro actually gates**, and in the order a user values it: the STATS tab, clips
/// (recording and watching, in MyDay and on DISCOVER), the PERFORMANCE tab, and the badge. The old
/// list sold features that were free or had been retired, which is the fastest route to a refund
/// request. When pro gates something new — coaching is next — add it here, and not before it ships.
struct ProFeatureList: View {

    struct Feature: Hashable {
        let icon: String
        let title: String
        let detail: String
    }

    static let features: [Feature] = [
        Feature(
            icon: "chart.bar.fill",
            title: "Your full stats",
            detail: "Weekly volume, streaks, training load and progress for every exercise"
        ),
        Feature(
            icon: "video.fill",
            title: "Exercise clips",
            detail: "Record your sets, check your form, and watch clips from the community"
        ),
        Feature(
            icon: "figure.jumprope",
            title: "Performance testing",
            detail: "Jump and balance tests measured on your phone, with every result tracked"
        ),
        Feature(
            icon: "gauge.with.dots.needle.50percent",
            title: "Weekly fatigue check",
            detail: "Know whether you're fresh or fatigued before you train"
        ),
        Feature(
            icon: "crown.fill",
            title: "Pro badge",
            detail: "Shown on your profile"
        )
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            ForEach(Self.features, id: \.self) { feature in
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: feature.icon)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color(.premiumColour))
                        .frame(width: 32, height: 32)
                        .background(
                            RoundedRectangle(cornerRadius: 9, style: .continuous)
                                .fill(Color(.premiumColour).opacity(0.15))
                        )
                    VStack(alignment: .leading, spacing: 2) {
                        Text(feature.title)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Color.primary)
                        Text(feature.detail)
                            .font(.system(size: 13))
                            .foregroundStyle(Color.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer(minLength: 0)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    ProFeatureList()
        .padding()
}
