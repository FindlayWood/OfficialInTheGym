//
//  ProPlanCard.swift
//  InTheGym
//
//  Created by Findlay Wood on 09/08/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import SwiftUI

/// One plan the paywall sells.
///
/// The recommended plan is drawn bigger than the others — a badge on its top edge, the free trial
/// written under its price, and its saving in a chip — so the eye lands on it before reading a
/// number. The other two stay plain: they are there to be compared against, not to compete. Every
/// card shows its real price for its real period first; equivalents ("£1.38 / week") are secondary
/// text, never the headline, so no plan's actual charge is hidden behind a smaller-looking number.
struct ProPlanCard: View {

    let plan: ProPlan
    let savingsPercent: Int?
    /// Drawn on the top edge of the recommended plan only — see `ProPlan.badgeTitle(among:)`.
    let badgeTitle: String?
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundStyle(isSelected ? Color(.premiumColour) : Color(.tertiaryLabel))

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 8) {
                        Text(plan.period.title)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(Color.primary)
                        if let savingsPercent {
                            Text("Save \(savingsPercent)%")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(Color(.premiumColour))
                                .padding(.horizontal, 7)
                                .padding(.vertical, 3)
                                .background(Capsule().fill(Color(.premiumColour).opacity(0.15)))
                        }
                    }
                    if let days = plan.freeTrialDays {
                        Text("\(days)-day free trial")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color(.premiumColour))
                    }
                }

                Spacer(minLength: 0)

                VStack(alignment: .trailing, spacing: 3) {
                    Text(plan.priceText)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.primary)
                    if let equivalent = plan.equivalentText {
                        Text(equivalent)
                            .font(.system(size: 13))
                            .foregroundStyle(Color.secondary)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, plan.isRecommended ? 22 : 16)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color(.secondarySystemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(isSelected ? Color(.premiumColour) : Color.clear, lineWidth: 2)
            )
            .overlay(alignment: .top) {
                if let badgeTitle {
                    Text(badgeTitle)
                        .font(.system(size: 11, weight: .bold))
                        .tracking(0.8)
                        .foregroundStyle(Color.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(Color(.premiumColour)))
                        .offset(y: -11)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(.top, plan.isRecommended ? 8 : 0)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    let plans = ProPlan.plans(from: SampleProduct.samples)
    VStack(spacing: 10) {
        ForEach(plans) { plan in
            ProPlanCard(
                plan: plan,
                savingsPercent: plan.isRecommended ? plan.savingsPercent(against: plans[1]) : nil,
                badgeTitle: plan.isRecommended ? plan.badgeTitle(among: plans) : nil,
                isSelected: plan.isRecommended,
                onTap: {}
            )
        }
    }
    .padding()
}
