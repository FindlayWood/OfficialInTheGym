//
//  ScheduleWeekdayPicker.swift
//  MyDayKit
//
//  Created by Findlay Wood on 08/11/2026.
//

import SwiftUI

/// Seven chips, Monday first, any number selected.
struct ScheduleWeekdayPicker: View {

    let selected: Set<ScheduleWeekday>
    let onToggle: (ScheduleWeekday) -> Void

    var body: some View {
        HStack(spacing: 6) {
            ForEach(ScheduleWeekday.allCases, id: \.self) { weekday in
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
    }
}
