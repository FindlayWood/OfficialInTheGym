//
//  AccountCreationErrorBanner.swift
//  AccountCreationKit
//
//  Created by Findlay Wood on 09/08/2026.
//

import SwiftUI

/// Sits above the bottom button, so a failure is reported next to the control that caused it
/// whichever step the user is on. Account creation used to fail silently — the spinner vanished and
/// nothing else changed.
struct AccountCreationErrorBanner: View {

    let message: String

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.red)
            Text(message)
                .font(.system(size: 13))
                .foregroundStyle(Color.primary)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.red.opacity(0.12))
        )
        .transition(.opacity)
    }
}

#Preview {
    AccountCreationErrorBanner(message: "We couldn't create your account. Check your connection and try again.")
        .padding()
}
