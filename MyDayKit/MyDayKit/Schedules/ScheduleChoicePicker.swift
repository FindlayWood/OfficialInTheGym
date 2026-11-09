//
//  ScheduleChoicePicker.swift
//  MyDayKit
//
//  Created by Findlay Wood on 08/11/2026.
//

import SwiftUI

/// Evenly split buttons with one selected, for "how often" and "which week".
struct ScheduleChoicePicker<Choice: Hashable>: View {

    let choices: [Choice]
    @Binding var selection: Choice
    let label: (Choice) -> String

    var body: some View {
        HStack(spacing: 8) {
            ForEach(choices, id: \.self) { choice in
                let isSelected = selection == choice
                Button {
                    selection = choice
                } label: {
                    Text(label(choice))
                        .font(.system(size: 14, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(isSelected ? Color.darkColor : Color(.tertiarySystemBackground))
                        )
                        .foregroundStyle(isSelected ? Color.white : Color.secondary)
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(isSelected ? .isSelected : [])
            }
        }
    }
}
