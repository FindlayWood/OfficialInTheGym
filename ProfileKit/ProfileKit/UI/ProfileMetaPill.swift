//
//  ProfileMetaPill.swift
//  ProfileKit
//
//  Created by Findlay Wood on 12/11/2026.
//

import SwiftUI

/// A small icon-and-text capsule on a workout row: exercise count, rating, comments.
///
/// **ProfileKit's copy of DiscoverKit's `DiscoverMetaPill`, kept in step with it**: a deliberate
/// duplicate across a module boundary, as the colour extensions are, so a workout reads the same on
/// a profile as in DISCOVER.
struct ProfileMetaPill: View {
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
