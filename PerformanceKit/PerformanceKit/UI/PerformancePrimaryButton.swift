//
//  PerformancePrimaryButton.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import SwiftUI

/// The forward action at the bottom of a screen: full width, 52pt, radius 14,
/// `darkColor`, as on every MyDay builder screen. Disabled is the gated style
/// from `SessionSetDetailOverlay` (`Color.secondary` on `tertiarySystemFill`,
/// `.easeInOut(0.15)`). **Keep it in step with that one** rather than
/// inventing a second look. A spinner replaces the title while working.
struct PerformancePrimaryButton: View {

    let title: String
    var isEnabled = true
    var isWorking = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                if isWorking {
                    ProgressView().tint(.white)
                } else {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(isEnabled ? Color.white : Color.secondary)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(isEnabled ? Color.darkColor : Color(.tertiarySystemFill))
            )
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled || isWorking)
        .animation(.easeInOut(duration: 0.15), value: isEnabled)
    }
}
