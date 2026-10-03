//
//  EditProfileFieldCard.swift
//  ProfileKit
//
//  Created by Findlay Wood on 03/10/2026.
//

import SwiftUI

/// A labelled input with a character counter: ProfileKit's copy of
/// `AccountCreationFieldCard` / `LoginFieldCard`, **kept in step with them**, so
/// editing a profile looks like creating one. It is a deliberate duplicate
/// across a module boundary until the shared UI framework exists.
struct EditProfileFieldCard<Content: View>: View {

    let title: String
    let icon: String
    var counter: String?
    var footer: String?
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
                        .font(.system(size: 12, weight: .medium).monospacedDigit())
                        .foregroundStyle(Color(.tertiaryLabel))
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
                Text(footer)
                    .font(.system(size: 13))
                    .foregroundStyle(Color.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
    }
}
