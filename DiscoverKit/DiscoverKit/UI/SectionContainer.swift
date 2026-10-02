//
//  SectionContainer.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 28/09/2026.
//

import SwiftUI

/// A titled card on the `darkColor` page — DiscoverKit's copy of StatsKit's
/// `SectionContainer`, **kept in step with it** so moving between the two tabs
/// does not change the frame of the app.
///
/// **The header sits on the page, not on the card**, which is why the title is
/// `.white`. Anything passed as `headerTrailing` must be light too: StatsKit
/// shipped a "View all" in `darkColor` — the page colour — which was present,
/// tappable and invisible.
struct SectionContainer<Content: View>: View {
    let title: String?
    let headerTrailing: AnyView?
    let content: Content

    init(
        title: String? = nil,
        headerTrailing: AnyView? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.headerTrailing = headerTrailing
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let title {
                HStack {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .textCase(.uppercase)
                        .tracking(0.5)
                    Spacer()
                    headerTrailing
                }
                .padding(.bottom, 8)
                .padding(.horizontal, 2)
            }

            VStack(alignment: .leading, spacing: 0) {
                content
            }
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(.separator).opacity(0.4), lineWidth: 0.5)
            )
        }
    }
}
