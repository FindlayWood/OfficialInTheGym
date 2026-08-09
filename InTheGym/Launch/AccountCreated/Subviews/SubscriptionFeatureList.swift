//
//  SubscriptionFeatureList.swift
//  InTheGym
//
//  Created by Findlay Wood on 09/08/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import SwiftUI

/// What pro includes. The rows were seven hand-written `HStack`s; the copy is unchanged.
struct SubscriptionFeatureList: View {

    static let features: [String] = [
        "Record Clips",
        "Watch Clips",
        "Individual Exercise Stats",
        "Vertical Jump Stats",
        "CMJ stats",
        "Injury tracker",
        "Journal"
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("What INTHEGYM pro includes")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.secondary)
                .textCase(.uppercase)
                .tracking(0.8)

            VStack(alignment: .leading, spacing: 10) {
                ForEach(Self.features, id: \.self) { feature in
                    HStack(spacing: 10) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(Color(.premiumColour))
                            .frame(width: 18)
                        Text(feature)
                            .font(.system(size: 15))
                            .foregroundStyle(Color.primary)
                        Spacer(minLength: 0)
                    }
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

#Preview {
    SubscriptionFeatureList()
        .padding()
}
