//
//  DiscoverCardChrome.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 06/10/2026.
//

import SwiftUI

extension View {

    /// The white radius-16 card with a hairline stroke that DISCOVER draws on its
    /// `darkColor` page. **The one definition of that chrome** — `SectionContainer`
    /// draws its card with it, and so does a workout that stands as a card of its
    /// own, so the two cannot drift.
    func discoverCardChrome() -> some View {
        background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(.separator).opacity(0.4), lineWidth: 0.5)
            )
    }
}
