//
//  ProfileSettingsRow.swift
//  ProfileKit
//
//  Created by Findlay Wood on 03/10/2026.
//

import SwiftUI

/// One row of a `ProfileSettingsSection`: icon, title, and a trailing detail,
/// spinner or chevron.
///
/// `tint` colours the icon only. A destructive row (Log Out, and later Delete
/// Account) is red in both icon and title.
///
/// A row with no `action` is information only (the version, the subscription
/// status). It draws no chevron and is not a button, so nothing on the screen
/// looks tappable without being tappable.
struct ProfileSettingsRow: View {

    enum Trailing {
        case chevron
        case detail(String)
        case progress
        case none
    }

    let icon: String
    let title: String
    var tint: Color = .darkColor
    var isDestructive = false
    var trailing: Trailing = .chevron
    var showsDivider = true
    var action: (() -> Void)?

    var body: some View {
        VStack(spacing: 0) {
            if let action {
                Button(action: action) { content }
                    .buttonStyle(.plain)
            } else {
                content
            }
            if showsDivider {
                Divider().padding(.leading, 52)
            }
        }
    }

    private var content: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(isDestructive ? Color.red : tint)
                .frame(width: 24)
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(isDestructive ? Color.red : Color.primary)
            Spacer(minLength: 12)
            trailingView
        }
        .padding(.horizontal, 14)
        .frame(minHeight: 52)
        .contentShape(Rectangle())
    }

    @ViewBuilder
    private var trailingView: some View {
        switch trailing {
        case .chevron:
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color(.tertiaryLabel))
        case .detail(let text):
            Text(text)
                .font(.system(size: 15))
                .foregroundStyle(Color.secondary)
                .lineLimit(1)
        case .progress:
            ProgressView()
        case .none:
            EmptyView()
        }
    }
}
