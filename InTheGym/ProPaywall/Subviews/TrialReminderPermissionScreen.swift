//
//  TrialReminderPermissionScreen.swift
//  InTheGym
//
//  Created by Findlay Wood on 12/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import SwiftUI

/// Shown straight after a free trial starts, to deliver the reminder the paywall promised.
///
/// **The app's one notification ask.** It replaced the system prompt the app used to show at first
/// launch, before signup, when nobody had a reason to say yes — and iOS shows that prompt only once.
/// Here the reason is a date on screen and a charge the user has just agreed to, which is the moment
/// people say yes. "Not now" costs nothing: the system prompt is left unused for a later ask.
///
/// Someone who turned notifications off earlier cannot be prompted again, so they get "Open
/// Settings" instead; coming back to the app re-checks (`recheckTrialReminderPermission`).
///
/// Only the trial reminder is promised, because it is the only notification a subscriber gets
/// today. When comments, likes and replies send pushes, a version of this screen asks for those too.
struct TrialReminderPermissionScreen: View {

    let trial: StartedTrial
    let permission: TrialReminderPermission
    let onAllow: () -> Void
    let onSkip: () -> Void

    @Environment(\.openURL) private var openURL

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Image(systemName: permission == .denied ? "bell.slash.fill" : "bell.badge.fill")
                .font(.system(size: 34, weight: .semibold))
                .foregroundStyle(Color.white)
                .frame(width: 84, height: 84)
                .background(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(Color(.premiumColour))
                )

            Text(title)
                .font(.system(size: 26, weight: .bold))
                .multilineTextAlignment(.center)
                .padding(.top, 24)

            Text(message)
                .font(.system(size: 16))
                .foregroundStyle(Color.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 10)

            reminderCard
                .padding(.top, 28)

            Spacer()

            VStack(spacing: 12) {
                Button {
                    if permission == .denied {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            openURL(url)
                        }
                    } else {
                        onAllow()
                    }
                } label: {
                    Text(permission == .denied ? "Open Settings" : "Remind me")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Color.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(Color(.premiumColour))
                        )
                }

                Button(action: onSkip) {
                    Text(permission == .denied ? "Continue without a reminder" : "Not now")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Color.secondary)
                        .frame(height: 44)
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground).ignoresSafeArea())
    }

    private var title: String {
        permission == .denied ? "Notifications are off" : "Your trial has started"
    }

    private var message: String {
        permission == .denied
            ? "Turn on notifications for INTHEGYM in Settings and we'll remind you before your trial ends."
            : "Allow notifications and we'll remind you the day before your trial ends, so nothing catches you out."
    }

    /// The two dates, again, so the user is agreeing to something specific.
    private var reminderCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            row(icon: "bell.fill", title: "Reminder", value: StartedTrial.display(trial.remindsAt))
            Divider()
            row(icon: "creditcard.fill", title: "First charge, \(trial.priceText)", value: StartedTrial.display(trial.endsAt))
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
    }

    private func row(icon: String, title: String, value: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color(.premiumColour))
                .frame(width: 20)
            Text(title)
                .font(.system(size: 14))
                .foregroundStyle(Color.secondary)
            Spacer(minLength: 8)
            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.primary)
                .multilineTextAlignment(.trailing)
        }
    }
}

#Preview {
    TrialReminderPermissionScreen(
        trial: StartedTrial(startedAt: Date(), days: 14, priceText: "£59.99 / year"),
        permission: .notAsked,
        onAllow: {},
        onSkip: {}
    )
}
