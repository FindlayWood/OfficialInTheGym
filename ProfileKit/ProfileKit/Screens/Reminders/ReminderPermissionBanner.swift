//
//  ReminderPermissionBanner.swift
//  ProfileKit
//
//  Created by Findlay Wood on 09/11/2026.
//

import SwiftUI

/// Shown when notifications are off for the app in Settings. Only the Settings app can turn them
/// back on, so the banner's one action goes there; the screen re-checks when the app returns.
struct ReminderPermissionBanner: View {

    let hasRemindersOn: Bool
    let onOpenSettings: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "bell.slash")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.secondary)
                Text(message)
                    .font(.system(size: 14))
                    .foregroundStyle(Color.primary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Button(action: onOpenSettings) {
                Text("Open Settings")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.darkColor)
            }
            .buttonStyle(.plain)
            .padding(.leading, 25)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
    }

    private var message: String {
        hasRemindersOn
            ? "Notifications are off for INTHEGYM, so these reminders won't arrive. Turn them on in Settings."
            : "Notifications are off for INTHEGYM. Turn them on in Settings to get reminders."
    }
}
