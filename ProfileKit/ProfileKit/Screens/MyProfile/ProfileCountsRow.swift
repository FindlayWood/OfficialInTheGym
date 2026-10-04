//
//  ProfileCountsRow.swift
//  ProfileKit
//
//  Created by Findlay Wood on 04/10/2026.
//

import SwiftUI

/// "12 Followers · 30 Following" under the name, each half opening its list.
/// The number leads, bold, because it is what the eye looks for. It is the
/// shape the legacy header's follower view had, without the boxes.
struct ProfileCountsRow: View {

    let counts: ProfileCounts
    let onFollowers: () -> Void
    let onFollowing: () -> Void

    var body: some View {
        HStack(spacing: 20) {
            count(counts.followers, label: counts.followers == 1 ? "Follower" : "Followers", action: onFollowers)
            count(counts.following, label: "Following", action: onFollowing)
        }
    }

    private func count(_ value: Int, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(value.formatted())
                    .font(.system(size: 15, weight: .bold).monospacedDigit())
                    .foregroundStyle(Color.primary)
                Text(label)
                    .font(.system(size: 15))
                    .foregroundStyle(Color.secondary)
            }
        }
        .buttonStyle(.plain)
    }
}
