//
//  AccountCreationTopBar.swift
//  AccountCreationKit
//
//  Created by Findlay Wood on 09/08/2026.
//

import SwiftUI

/// Back and sign out, drawn like `MyDayWorkoutNavBar` — a plain 44pt chevron in `darkColor` rather
/// than the 60pt filled circles this flow used to put at the bottom of every step.
///
/// Sign out is the only way out of onboarding, so it has to be reachable, but it is an escape hatch
/// rather than a choice being offered. It used to sit in red directly beneath "Get Started", two
/// stacked buttons with the destructive-looking one under the primary — which read as an error
/// state. It is now a quiet text button in the corner, and only on the first step, where leaving is
/// the only thing back could mean.
struct AccountCreationTopBar: View {

    let showsBack: Bool
    let showsSignOut: Bool

    var onBack: (() -> Void)?
    var onSignOut: (() -> Void)?

    var body: some View {
        HStack(spacing: 0) {
            if showsBack {
                Button {
                    onBack?()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Color.darkColor)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
            } else {
                Color.clear.frame(width: 44, height: 44)
            }

            Spacer()

            if showsSignOut {
                Button {
                    onSignOut?()
                } label: {
                    Text("Sign Out")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Color.secondary)
                        .padding(.horizontal, 12)
                        .frame(height: 44)
                        .contentShape(Rectangle())
                }
            }
        }
        .padding(.horizontal, 8)
    }
}

#Preview {
    AccountCreationTopBar(showsBack: true, showsSignOut: true)
}
