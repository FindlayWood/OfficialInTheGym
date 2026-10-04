//
//  ProfileSettingsToggleRow.swift
//  ProfileKit
//
//  Created by Findlay Wood on 04/10/2026.
//

import SwiftUI

/// A settings row with a switch: the same icon and title as
/// `ProfileSettingsRow`, the switch tinted `darkColor` rather than system green.
/// A spinner replaces the switch while its change is saving, so it cannot be
/// flipped again mid-write.
struct ProfileSettingsToggleRow: View {

    let icon: String
    let title: String
    @Binding var isOn: Bool
    var isSaving = false
    var isEnabled = true
    var showsDivider = true

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.darkColor)
                    .frame(width: 24)
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Color.primary)
                Spacer(minLength: 12)
                if isSaving {
                    ProgressView()
                } else {
                    Toggle(title, isOn: $isOn)
                        .labelsHidden()
                        .tint(Color.darkColor)
                        .disabled(!isEnabled)
                }
            }
            .padding(.horizontal, 14)
            .frame(minHeight: 52)
            if showsDivider {
                Divider().padding(.leading, 52)
            }
        }
    }
}
