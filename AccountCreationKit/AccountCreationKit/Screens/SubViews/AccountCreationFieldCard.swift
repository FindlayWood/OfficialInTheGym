//
//  AccountCreationFieldCard.swift
//  AccountCreationKit
//
//  Created by Findlay Wood on 09/08/2026.
//

import SwiftUI

struct AccountCreationFieldFooter {
    let message: String
    let isError: Bool
}

/// A labelled input, built like `WorkoutSettingsSheet.SettingsCard`: a `secondarySystemBackground`
/// card with an uppercase caption header, holding a `tertiarySystemBackground` input well.
///
/// This replaced a white capsule with `shadow(radius: 8)` — which was unreadable in dark mode, since
/// the background was hardcoded `.white` while the text stayed `.primary`.
struct AccountCreationFieldCard<Content: View>: View {

    let title: String
    let icon: String
    var counter: String?
    var footer: AccountCreationFieldFooter?
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 7) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.darkColor)
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.secondary)
                    .textCase(.uppercase)
                    .tracking(0.8)

                Spacer()

                if let counter {
                    Text(counter)
                        .font(.system(size: 12))
                        .foregroundStyle(Color(.tertiaryLabel))
                        .monospacedDigit()
                }
            }

            content
                .padding(.horizontal, 12)
                .padding(.vertical, 11)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color(.tertiarySystemBackground))
                )

            if let footer {
                Text(footer.message)
                    .font(.system(size: 13))
                    .foregroundStyle(footer.isError ? Color.red : Color.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .transition(.opacity)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

#Preview {
    AccountCreationFieldCard(
        title: "Username",
        icon: "at",
        counter: "4/50",
        footer: .init(message: "That username is already taken.", isError: true)
    ) {
        Text("findlay")
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    .padding()
}
