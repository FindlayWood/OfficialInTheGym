//
//  DiscoverSeparateCardsSection.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 06/10/2026.
//

import SwiftUI

/// A section whose items are cards of their own, spaced apart on the page,
/// rather than rows joined by dividers inside one `SectionContainer` card.
/// Workouts are listed this way: each is tall enough, and carries enough of
/// its own detail, to read as a thing rather than a line in a table.
///
/// It draws no chrome itself. Each item brings its own `discoverCardChrome()` —
/// `DiscoverWorkoutRow` and its skeleton always do — and a message standing in
/// for the list (empty, failed) is wrapped by the caller.
struct DiscoverSeparateCardsSection<Content: View>: View {
    let title: String?
    var headerTrailing: AnyView?
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let title {
                DiscoverSectionHeader(title: title, trailing: headerTrailing)
            }
            LazyVStack(spacing: 10) {
                content
            }
        }
    }
}
