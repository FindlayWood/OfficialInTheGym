//
//  DiscoverTagChip.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 30/09/2026.
//

import SwiftUI

/// One tag as a capsule, with an optional vote count.
///
/// Three looks, and they mean different things: `.plain` is a tag on the
/// subject; `.mine` is one the user has voted for (filled `darkColor` — a
/// selection); `.pending` is the user's vote on a tag not yet visible to
/// anyone else, drawn outlined so it does not read as agreed.
struct DiscoverTagChip: View {

    enum Style {
        case plain
        case mine
        case pending
    }

    let tag: String
    var count: Int?
    var style: Style = .plain

    var body: some View {
        HStack(spacing: 5) {
            Text("#\(tag)")
                .font(.system(size: 14, weight: .semibold))
            if let count, count > 0 {
                Text("\(count)")
                    .font(.system(size: 12, weight: .medium))
                    .opacity(0.7)
            }
        }
        .foregroundStyle(style == .mine ? .white : Color.darkColor)
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
        .background {
            switch style {
            case .plain:
                Capsule().fill(Color(.tertiarySystemFill))
            case .mine:
                Capsule().fill(Color.darkColor)
            case .pending:
                Capsule().strokeBorder(Color.darkColor, style: StrokeStyle(lineWidth: 1, dash: [4, 3]))
            }
        }
        .contentShape(Capsule())
    }
}
