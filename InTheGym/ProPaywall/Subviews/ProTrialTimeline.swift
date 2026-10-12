//
//  ProTrialTimeline.swift
//  InTheGym
//
//  Created by Findlay Wood on 11/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import SwiftUI

/// How the free trial plays out, as three dated steps — today, the reminder, the first charge —
/// with the reminder toggle on its middle step.
///
/// The fear that stops people starting a trial is being charged for something they forgot about.
/// Saying "cancel anytime" answers it in the abstract; putting **the actual date of the charge**
/// on screen, and the reminder the day before it, answers it concretely. Real dates, not "day 13":
/// a user should not have to count.
///
/// The reminder step names the date only while the toggle is on. Off, the step still shows the
/// trial ending, so the timeline never tells someone they will be reminded when they will not.
struct ProTrialTimeline: View {

    let trialDays: Int
    let priceText: String
    let remindBeforeTrialEnds: Bool
    let notificationsBlocked: Bool
    let onReminderChange: (Bool) -> Void

    private var startDate: Date { Date() }
    private var endDate: Date {
        Calendar.current.date(byAdding: .day, value: trialDays, to: startDate) ?? startDate
    }
    private var reminderDate: Date {
        Calendar.current.date(byAdding: .day, value: -1, to: endDate) ?? endDate
    }

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
            ) {
                EmptyView()
            }

            step(
                icon: remindBeforeTrialEnds ? "bell.fill" : "bell.slash.fill",
                title: Self.dateFormatter.string(from: reminderDate),
                detail: remindBeforeTrialEnds
                    ? "We'll send you a reminder that your trial ends tomorrow."
                    : "Your trial ends tomorrow. You won't get a reminder.",
                isLast: false
            ) {
                reminderToggle
            }

            step(
                icon: "creditcard.fill",
                title: Self.dateFormatter.string(from: endDate),
                detail: "You'll be charged \(priceText). Cancel before then and you pay nothing.",
                isLast: true
            ) {
                EmptyView()
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
    }

    private var reminderToggle: some View {
        VStack(alignment: .leading, spacing: 6) {
            Toggle(isOn: Binding(
                get: { remindBeforeTrialEnds },
                set: { onReminderChange($0) }
            )) {
                Text("Remind me before my trial ends")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.primary)
            }
            .tint(Color(.premiumColour))

            if notificationsBlocked {
                Text("Notifications are off for INTHEGYM. Turn them on in Settings to get the reminder.")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(.tertiarySystemBackground))
        )
        .padding(.top, 8)
    }

    private func step<Accessory: View>(
        icon: String,
        title: String,
        detail: String,
        isLast: Bool,
        @ViewBuilder accessory: () -> Accessory
    ) -> some View {
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
                accessory()
            }
            .padding(.bottom, isLast ? 0 : 16)
        }
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("EEEE d MMMM")
        return formatter
    }()
}

#Preview {
    ProTrialTimeline(
        trialDays: 14,
        priceText: "£5.99 / month",
        remindBeforeTrialEnds: true,
        notificationsBlocked: false,
        onReminderChange: { _ in }
    )
    .padding()
}
