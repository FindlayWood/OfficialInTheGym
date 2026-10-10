//
//  PerformancePillPicker.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import SwiftUI

/// A choice between a few options as pills: the selected one filled
/// `darkColor` with white text, the rest `tertiarySystemFill`. MyDay's unit
/// pickers look this way; the system segmented control does not take the
/// brand colour.
struct PerformancePillPicker<Option: Hashable>: View {

    let options: [Option]
    @Binding var selection: Option
    let label: (Option) -> String

    var body: some View {
        HStack(spacing: 6) {
            ForEach(options, id: \.self) { option in
                let isSelected = option == selection
                Button {
                    withAnimation(.easeInOut(duration: 0.15)) { selection = option }
                } label: {
                    Text(label(option))
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(isSelected ? Color.white : Color.secondary)
                        .padding(.horizontal, 14)
                        .frame(height: 32)
                        .background(
                            Capsule().fill(isSelected ? Color.darkColor : Color(.tertiarySystemFill))
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }
}
