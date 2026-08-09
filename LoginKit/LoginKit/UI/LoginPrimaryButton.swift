//
//  LoginPrimaryButton.swift
//  LoginKit
//
//  Created by Findlay Wood on 09/08/2026.
//

import SwiftUI

/// The full-width 52pt action, matching every MyDay builder screen and the account creation flow.
///
/// Disabled styling is the one `SessionSetDetailOverlay`'s log button established — `Color.secondary`
/// on `tertiarySystemFill`, `.easeInOut(0.15)` — rather than the filled colour at 30% opacity these
/// screens used, which read as "loading" more than "not yet".
struct LoginPrimaryButton: View {

    let title: String
    var isEnabled: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(isEnabled ? Color.white : Color.secondary)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(isEnabled ? Color.darkColor : Color(UIColor.tertiarySystemFill))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .disabled(!isEnabled)
        .animation(.easeInOut(duration: 0.15), value: isEnabled)
    }
}

/// The quieter partner to `LoginPrimaryButton`, in the tinted style
/// `MyDayWorkoutLibraryScreen` uses for "Try Again".
struct LoginSecondaryButton: View {

    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.darkColor)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(Color.darkColor.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }
}
