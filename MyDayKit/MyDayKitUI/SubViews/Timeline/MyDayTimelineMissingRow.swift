//
//  MyDayTimelineMissingRow.swift
//  MyDayKit
//
//  Created by Findlay Wood on 18/10/2026.
//

import SwiftUI

/// A step a past day never had: the step's name on the left, "Not recorded" on the right, and a
/// hairline under it unless it is the last step. A row, not a card — past days cannot be edited,
/// so there is nothing to offer, and a full card saying nothing is what the old empty state did.
///
/// It was first a single grey caption ("No check-in"), which on a day with nothing logged left
/// three small lines on an empty page that read as unfinished rather than minimal. Naming the
/// step and stating its status makes the same three facts read as a list.
///
/// It never says "Rest day" — nothing being logged is not the same as the user having rested,
/// and the screen only knows the first.
struct MyDayTimelineMissingRow: View {
    let title: String
    var showsDivider: Bool = true

    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Color.white)
            Spacer()
            Text("Not recorded")
                .font(.system(size: 13, weight: .regular))
                .foregroundStyle(Color.white.opacity(0.6))
        }
        .padding(.top, 16)
        .padding(.bottom, 12)
        .overlay(alignment: .bottom) {
            if showsDivider {
                Rectangle()
                    .fill(Color.white.opacity(0.12))
                    .frame(height: 0.5)
            }
        }
    }
}
