//
//  MyDaySignupBadge.swift
//  MyDayKit
//
//  Created by Findlay Wood on 19/10/2026.
//

import SwiftUI

/// Marks the day the user joined, wherever a day is drawn as a pill: the date
/// strip, `MyDayWeekCard`, and the legend that explains it. The welcome card's
/// sparkles, so the mark and the card read as the same thing.
///
/// **A badge, not an outline or a fourth dot.** An outline already means "the
/// day you are viewing" in the week card, and the strip's three dots are fixed
/// slots — a fourth would break the rule that a dot's position is its meaning.
/// The ring in the page colour keeps it separate from a selected `darkColor`
/// pill it overlaps.
struct MyDaySignupBadge: View {
    var size: CGFloat = 16

    var body: some View {
        Image(systemName: "sparkles")
            .font(.system(size: size * 0.5, weight: .bold))
            .foregroundStyle(Color.white)
            .frame(width: size, height: size)
            .background(Color.darkColor)
            .clipShape(Circle())
            .overlay {
                Circle().strokeBorder(Color(UIColor.systemBackground), lineWidth: 1.5)
            }
            .accessibilityLabel("The day you joined")
    }
}
