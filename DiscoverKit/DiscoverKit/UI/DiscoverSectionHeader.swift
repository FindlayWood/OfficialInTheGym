//
//  DiscoverSectionHeader.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 06/10/2026.
//

import SwiftUI

/// A section's uppercase title, with an optional trailing control, sitting on
/// the `darkColor` page above its content — which is why it is `.white`, and
/// why anything passed as `trailing` must be light too. Shared by
/// `SectionContainer` and `DiscoverSeparateCardsSection`, so a section of
/// joined rows and a section of separate cards are headed identically.
struct DiscoverSectionHeader: View {
    let title: String
    var trailing: AnyView?

    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .textCase(.uppercase)
                .tracking(0.5)
            Spacer()
            trailing
        }
        .padding(.bottom, 8)
        .padding(.horizontal, 2)
    }
}
