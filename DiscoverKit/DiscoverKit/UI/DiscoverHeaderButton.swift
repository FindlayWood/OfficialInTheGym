//
//  DiscoverHeaderButton.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 30/09/2026.
//

import SwiftUI

/// An action in a `SectionContainer` header — white on a translucent white
/// capsule, the same as `SeeAllButton`, because a header sits on the
/// `darkColor` page and anything on it must be light.
struct DiscoverHeaderButton: View {
    let title: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: systemImage)
                    .font(.system(size: 11, weight: .semibold))
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color.white.opacity(0.18), in: Capsule())
        }
        .buttonStyle(.plain)
    }
}
