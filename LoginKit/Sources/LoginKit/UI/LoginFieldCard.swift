//
//  LoginFieldCard.swift
//  LoginKit
//
//  Created by Findlay Wood on 09/08/2026.
//

import SwiftUI

/// A labelled input — the same card `AccountCreationFieldCard` draws in AccountCreationKit, so the
/// screens either side of signup read as one flow.
///
/// This replaced a white capsule with `shadow(radius: 8)`, which was unreadable in dark mode: the
/// background was hardcoded `.white` while the text stayed `.primary`.
struct LoginFieldCard<Content: View>: View {

    let title: String
    let icon: String
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
