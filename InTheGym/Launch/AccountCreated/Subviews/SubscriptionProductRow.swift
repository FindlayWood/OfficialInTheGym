//
//  SubscriptionProductRow.swift
//  InTheGym
//
//  Created by Findlay Wood on 09/08/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import SwiftUI

/// One purchasable period.
///
/// The paywall used to inline this twice — a selected branch and an unselected one, identical apart
/// from the circle glyph and a border — which is why the two had already drifted apart in padding.
struct SubscriptionProductRow: View {

    let product: DisplayAndPurchaseProduct
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(product.period)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Color.primary)
                    HStack(spacing: 4) {
                        Text(product.displayPrice)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Color.primary)
                        Text("/ \(product.perPeriod)")
                            .font(.system(size: 15))
                            .foregroundStyle(Color.secondary)
                    }
                }

                Spacer(minLength: 0)

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20))
                    .foregroundStyle(isSelected ? Color(.premiumColour) : Color(.tertiaryLabel))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color(.secondarySystemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(isSelected ? Color(.premiumColour) : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}
