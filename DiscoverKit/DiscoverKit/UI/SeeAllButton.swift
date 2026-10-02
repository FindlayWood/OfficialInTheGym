//
//  SeeAllButton.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 28/09/2026.
//

import SwiftUI

/// The `headerTrailing` for a `SectionContainer`: white on a translucent white
/// capsule, matching StatsKit's "View all". It sits on the `darkColor` page, so
/// it must be light — see `SectionContainer`.
struct SeeAllButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text("See all")
                    .font(.system(size: 13, weight: .semibold))
                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .semibold))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color.white.opacity(0.18), in: Capsule())
        }
        .buttonStyle(.plain)
    }
}
