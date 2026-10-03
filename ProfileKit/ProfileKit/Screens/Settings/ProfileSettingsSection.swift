//
//  ProfileSettingsSection.swift
//  ProfileKit
//
//  Created by Findlay Wood on 03/10/2026.
//

import SwiftUI

/// A titled group of settings rows: an uppercase caption over a
/// `secondarySystemBackground` card, with an optional footer explaining the
/// group. It uses the caption style of `LoginFieldCard` / `AccountCreationFieldCard`.
///
/// A card rather than an `.insetGrouped` list, which the conventions rule out,
/// and so the screen matches the rest of onboarding and MyDay.
struct ProfileSettingsSection<Content: View>: View {

    let title: String
    var footer: String?
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.secondary)
                .textCase(.uppercase)
                .tracking(0.8)
                .padding(.horizontal, 4)

            VStack(spacing: 0) {
                content
            }
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(.secondarySystemBackground))
            )

            if let footer {
                Text(footer)
                    .font(.system(size: 13))
                    .foregroundStyle(Color.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 4)
            }
        }
    }
}
