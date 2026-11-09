//
//  ReminderSettingsViewModel.swift
//  ProfileKit
//
//  Created by Findlay Wood on 09/11/2026.
//

import Combine
import Foundation

/// Settings → Reminders. Every change is saved as it is made, as everywhere in the app — there
/// is no Save button, and leaving the screen keeps what is on it.
///
/// **Permission is asked when a reminder is first turned on, never before.** iOS shows its
/// prompt once, and this is the moment the user has a reason to say yes. If the answer is no,
/// the switch stays off and the banner says why — a switch that reads on while nothing can be
/// delivered would be a promise the app cannot keep.
@MainActor
final class ReminderSettingsViewModel: ObservableObject {

    // MARK: - Dependencies
    private let service: ReminderSettingsService

    // MARK: - Properties
    @Published private(set) var settings: ProfileReminderSettings
    /// `nil` until first read.
    @Published private(set) var permission: ProfileReminderPermission?
    @Published private(set) var isAskingPermission = false

    // MARK: - Init
    init(service: ReminderSettingsService) {
        self.service = service
        self.settings = service.loadSettings()
    }

    /// The banner shows when notifications are off in Settings — whether or not anything is on
    /// yet, since turning a switch on would only fail.
    var showsPermissionBanner: Bool {
        permission == .denied
    }

    func refreshPermission() async {
        permission = await service.permission()
    }

    func setOn(_ isOn: Bool, for kind: ProfileReminderKind) async {
        if isOn && permission != .allowed {
            isAskingPermission = true
            let granted = await service.requestPermission()
            permission = await service.permission()
            isAskingPermission = false
            guard granted else { return }
        }
        update(kind) { $0.isOn = isOn }
    }

    func setTime(hour: Int, minute: Int, for kind: ProfileReminderKind) {
        update(kind) {
            $0.hour = hour
            $0.minute = minute
        }
    }

    /// Toggles one weekday. The last one cannot be taken away: a reminder on with no days is a
    /// switch that reads on and never fires.
    func toggle(_ weekday: ProfileWeekday, for kind: ProfileReminderKind) {
        update(kind) { setting in
            if setting.weekdays.contains(weekday) {
                guard setting.weekdays.count > 1 else { return }
                setting.weekdays.remove(weekday)
            } else {
                setting.weekdays.insert(weekday)
            }
        }
    }

    private func update(_ kind: ProfileReminderKind, _ change: (inout ProfileReminderSetting) -> Void) {
        var next = settings
        change(&next[kind])
        guard next != settings else { return }
        settings = next
        service.save(next)
    }
}
