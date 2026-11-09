//
//  ReminderWeekdayPicker.swift
//  ProfileKit
//
//  Created by Findlay Wood on 09/11/2026.
//

import SwiftUI

/// Seven day chips, Monday first, for the days a reminder fires on. Drawn like MyDay's
/// `ScheduleWeekdayPicker` — **keep the two in step** — so a schedule's days and a reminder's days read as the same control.
struct ReminderWeekdayPicker: View {

    let selected: Set<ProfileWeekday>
    let onToggle: (ProfileWeekday) -> Void

    var body: some View {
        HStack(spacing: 6) {
            ForEach(ProfileWeekday.allCases, id: \.self) { weekday in
                let isSelected = selected.contains(weekday)
                Button {
                    onToggle(weekday)
                } label: {
                    Text(weekday.initial)
                        .font(.system(size: 15, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(isSelected ? Color.darkColor : Color(.tertiarySystemBackground))
                        )
                        .foregroundStyle(isSelected ? Color.white : Color.secondary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(weekday.fullName)
                .accessibilityAddTraits(isSelected ? .isSelected : [])
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .animation(.easeInOut(duration: 0.15), value: selected)
    }
}
