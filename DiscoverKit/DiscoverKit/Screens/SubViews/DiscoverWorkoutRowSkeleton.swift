//
//  DiscoverWorkoutRowSkeleton.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 05/10/2026.
//

import SwiftUI

/// A loading workout, shaped like `DiscoverWorkoutRow` — title, byline, a row
/// of pills — so a workout list fills in rather than growing taller as it
/// loads. `DiscoverRowSkeleton` is the icon-tile shape the exercise rows use.
struct DiscoverWorkoutRowSkeleton: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            VStack(alignment: .leading, spacing: 6) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(.tertiarySystemFill))
                    .frame(width: 180, height: 16)
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(.quaternarySystemFill))
                    .frame(width: 120, height: 11)
            }
            HStack(spacing: 6) {
                ForEach(0..<2, id: \.self) { _ in
                    Capsule()
                        .fill(Color(.quaternarySystemFill))
                        .frame(width: 80, height: 22)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
    }
}
