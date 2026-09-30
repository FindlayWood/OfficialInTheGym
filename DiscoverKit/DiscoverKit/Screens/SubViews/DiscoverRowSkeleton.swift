//
//  DiscoverRowSkeleton.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 28/09/2026.
//

import SwiftUI

/// A loading row shaped like the real one — tile, title bar, subtitle bar — so a
/// section fills in rather than swapping layouts, as the workout library's
/// skeleton does.
struct DiscoverRowSkeleton: View {
    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.tertiarySystemFill))
                .frame(width: 44, height: 44)
            VStack(alignment: .leading, spacing: 6) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(.tertiarySystemFill))
                    .frame(width: 150, height: 14)
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(.quaternarySystemFill))
                    .frame(width: 100, height: 11)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}
