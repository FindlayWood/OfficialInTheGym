//
//  ReminderTimeRow.swift
//  ProfileKit
//
//  Created by Findlay Wood on 09/11/2026.
//

import SwiftUI

/// The time a reminder fires, on the system's compact time picker.
///
/// The picker edits a `Date` only because that is what `DatePicker` takes; the row reads the hour
/// and minute back out of it, in the device calendar, and nothing else of the date is kept.
struct ReminderTimeRow: View {

    let hour: Int
    let minute: Int
    let onChange: (_ hour: Int, _ minute: Int) -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 14) {
                Image(systemName: "clock")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.darkColor)
                    .frame(width: 24)
                Text("Time")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Color.primary)
                Spacer(minLength: 12)
                DatePicker("Time", selection: selection, displayedComponents: .hourAndMinute)
                    .labelsHidden()
                    .tint(Color.darkColor)
            }
            .padding(.horizontal, 14)
            .frame(minHeight: 52)
            Divider().padding(.leading, 52)
        }
    }

    private var selection: Binding<Date> {
        Binding(
            get: {
                Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: Date()) ?? Date()
            },
            set: { date in
                let parts = Calendar.current.dateComponents([.hour, .minute], from: date)
                onChange(parts.hour ?? hour, parts.minute ?? minute)
            }
        )
    }
}
