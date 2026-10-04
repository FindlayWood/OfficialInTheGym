//
//  ProfileHeaderSkeleton.swift
//  ProfileKit
//
//  Created by Findlay Wood on 03/10/2026.
//

import SwiftUI

/// The loading state of `ProfileHeaderCard`, the same shape (circle, name bar,
/// username bar) inside the same card, so the header fills in rather than
/// swapping layouts. That is the reason the library skeleton mirrors its rows.
struct ProfileHeaderSkeleton: View {

    var body: some View {
        VStack(spacing: 14) {
            Circle()
                .fill(Color(.tertiarySystemFill))
                .frame(width: 88, height: 88)
            VStack(spacing: 8) {
                Capsule()
                    .fill(Color(.tertiarySystemFill))
                    .frame(width: 160, height: 18)
                Capsule()
                    .fill(Color(.tertiarySystemFill))
                    .frame(width: 96, height: 14)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
        .accessibilityLabel("Loading profile")
    }
}
