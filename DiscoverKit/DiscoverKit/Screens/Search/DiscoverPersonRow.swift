//
//  DiscoverPersonRow.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 05/10/2026.
//

import SwiftUI

/// A person in search results: initial, name over @username, and a chevron
/// when there is a profile to open. The 44pt avatar takes the slot the icon
/// tile takes on workout and exercise rows, so the three sections line up.
/// No follow button — following is a decision made on the profile, not from a
/// name in a list of matches.
struct DiscoverPersonRow: View {
    let person: DiscoverUserProfile
    let isTappable: Bool

    var body: some View {
        HStack(spacing: 12) {
            DiscoverCommentAvatar(initial: person.initial, size: 44)
            VStack(alignment: .leading, spacing: 3) {
                Text(person.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                Text("@\(person.username)")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Spacer(minLength: 0)
            if isTappable {
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }
}
