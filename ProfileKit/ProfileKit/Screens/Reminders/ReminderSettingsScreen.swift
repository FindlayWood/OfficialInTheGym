//
//  ReminderSettingsScreen.swift
//  ProfileKit
//
//  Created by Findlay Wood on 09/11/2026.
//

import SwiftUI
import UIKit

/// Settings → Reminders: one section per reminder, each a switch, and once it is on, the time
/// and the days. See `ReminderSettingsViewModel` and `READINESS_PLAN.md` part 1.
///
/// **The time and days only appear once the switch is on.** Shown for a reminder that is off,
/// they read as a reminder already set.
struct ReminderSettingsScreen: View {

    @ObservedObject var viewModel: ReminderSettingsViewModel
    @Environment(\.openURL) private var openURL

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                if viewModel.showsPermissionBanner {
                    ReminderPermissionBanner(hasRemindersOn: viewModel.settings.hasAnyOn) {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            openURL(url)
                        }
                    }
                }
                ForEach(ProfileReminderKind.allCases, id: \.self) { kind in
                    section(for: kind)
                }
            }
            .padding(16)
            .animation(.easeInOut(duration: 0.2), value: viewModel.settings)
        }
        .background(Color(.systemBackground).ignoresSafeArea())
        .navigationTitle("Reminders")
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.refreshPermission() }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            Task { await viewModel.refreshPermission() }
        }
    }

    private func section(for kind: ProfileReminderKind) -> some View {
        let setting = viewModel.settings[kind]
        return ProfileSettingsSection(title: kind.title, footer: kind.footer) {
            ProfileSettingsToggleRow(
                icon: kind.icon,
                title: "Remind me",
                isOn: Binding(
                    get: { setting.isOn },
                    set: { isOn in Task { await viewModel.setOn(isOn, for: kind) } }
                ),
                isSaving: viewModel.isAskingPermission,
                showsDivider: setting.isOn
            )
            if setting.isOn {
                ReminderTimeRow(hour: setting.hour, minute: setting.minute) { hour, minute in
                    viewModel.setTime(hour: hour, minute: minute, for: kind)
                }
                ReminderWeekdayPicker(selected: setting.weekdays) { weekday in
                    viewModel.toggle(weekday, for: kind)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ReminderSettingsScreen(viewModel: ReminderSettingsViewModel(service: PreviewReminderSettingsService()))
    }
}
