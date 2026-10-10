//
//  DiscoverMetaPill.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 05/10/2026.
//

import SwiftUI

/// One small fact on a card — exercise count, rating, comments — as a glyph and
/// a short label on a quiet capsule. Facts, not actions, so it is grey rather
/// than `darkColor`, which on DISCOVER marks something tappable or selected.
struct DiscoverMetaPill: View {
    let systemImage: String
    let text: String

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: systemImage)
                .font(.system(size: 10, weight: .semibold))
            Text(text)
                .font(.system(size: 12, weight: .medium))
                .lineLimit(1)
        }
        .foregroundStyle(.secondary)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color(.tertiarySystemFill), in: Capsule())
    }
}
