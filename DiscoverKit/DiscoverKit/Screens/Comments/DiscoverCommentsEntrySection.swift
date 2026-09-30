//
//  DiscoverCommentsEntrySection.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 30/09/2026.
//

import SwiftUI

/// The way into a subject's comments from its detail screen: how many there
/// are, and a row that opens them. The count is the card's, as of when the
/// screen opened.
struct DiscoverCommentsEntrySection: View {
    let count: Int
    let onOpen: () -> Void

    var body: some View {
        SectionContainer(title: "Comments") {
            Button(action: onOpen) {
                HStack {
                    Image(systemName: "bubble.left.and.bubble.right")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.darkColor)
                    Text(count == 0 ? "Start the conversation" : (count == 1 ? "1 comment" : "\(count) comments"))
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.primary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.tertiary)
                }
                .padding(16)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
    }
}
