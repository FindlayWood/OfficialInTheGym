//
//  DiscoverLikeButton.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 30/09/2026.
//

import SwiftUI

/// A heart and a count. Filled `darkColor` when liked — a selection is an
/// accent, and accents are `darkColor`, never the system red a heart usually
/// borrows.
struct DiscoverLikeButton: View {
    let isLiked: Bool
    let count: Int
    var tint: Color = .secondary
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: isLiked ? "heart.fill" : "heart")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(isLiked ? Color.darkColor : tint)
                if count > 0 {
                    Text("\(count)")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(tint)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.15), value: isLiked)
    }
}
