//
//  PerformanceRow.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import SwiftUI

/// A tappable row inside a card: icon tile, title, optional subtitle, chevron,
/// and a divider inset past the tile when another row follows. The shape of
/// MyDay's library row, joined into one card the way ProfileKit's settings
/// rows are.
struct PerformanceRow: View {

    let icon: String
    let title: String
    var subtitle: String?
    var showsDivider = false
    let action: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Button(action: action) {
                HStack(spacing: 14) {
                    PerformanceIconTile(systemName: icon)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(title)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color.primary)
                        if let subtitle {
                            Text(subtitle)
                                .font(.system(size: 13))
                                .foregroundStyle(Color.secondary)
                                .multilineTextAlignment(.leading)
                        }
                    }
                    Spacer(minLength: 12)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color(.tertiaryLabel))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            if showsDivider {
                Divider().padding(.leading, 74)
            }
        }
    }
}
