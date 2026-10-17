//
//  ProTrialTimeline.swift
//  InTheGym
//
//  Created by Findlay Wood on 11/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import SwiftUI

/// How the free trial plays out, as three dated steps — today, the reminder, the first charge.
///
/// The fear that stops people starting a trial is being charged for something they forgot about.
/// Saying "cancel anytime" answers it in the abstract; putting **the actual date of the charge**
/// on screen, and a reminder the day before it, answers it concretely. Real dates, not "day 13":
/// a user should not have to count.
///
/// **The reminder is promised here and asked for after the purchase**, on
/// `TrialReminderPermissionScreen`. It used to be a toggle on this card, but a toggle cannot ask
/// for notifications at a good moment — so the app asked at first launch instead, before anyone had
/// a reason to say yes. The promise stays on the paywall because it is part of what makes the trial
/// feel safe to start.
struct ProTrialTimeline: View {

    let trial: StartedTrial

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("How your free trial works")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.secondary)
                .textCase(.uppercase)
                .tracking(0.8)
                .padding(.bottom, 14)

            step(
                icon: "lock.open.fill",
                title: "Today",
                detail: "Full access to everything in pro. Nothing to pay today.",
                isLast: false
            )

            step(
                icon: "bell.fill",
                title: StartedTrial.display(trial.remindsAt),
                detail: "We'll send you a reminder that your trial ends tomorrow.",
                isLast: false
            )

            step(
                icon: "creditcard.fill",
                title: StartedTrial.display(trial.endsAt),
                detail: "You'll be charged \(trial.priceText). Cancel before then and you pay nothing.",
                isLast: true
            )
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
    }

    private func step(icon: String, title: String, detail: String, isLast: Bool) -> some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(spacing: 0) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.white)
                    .frame(width: 30, height: 30)
                    .background(Circle().fill(Color(.premiumColour)))
                if !isLast {
                    Rectangle()
                        .fill(Color(.premiumColour).opacity(0.3))
                        .frame(width: 2)
                        .frame(maxHeight: .infinity)
                }
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.primary)
                Text(detail)
                    .font(.system(size: 13))
                    .foregroundStyle(Color.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.bottom, isLast ? 0 : 16)
        }
    }
}

#Preview {
    ProTrialTimeline(trial: StartedTrial(startedAt: Date(), days: 14, priceText: "£59.99 / year"))
        .padding()
}
