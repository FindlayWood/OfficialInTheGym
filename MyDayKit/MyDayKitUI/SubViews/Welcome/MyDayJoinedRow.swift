//
//  MyDayJoinedRow.swift
//  MyDayKit
//
//  Created by Findlay Wood on 19/10/2026.
//

import SwiftUI

/// The signup day, seen from any later day: one quiet line saying this is when
/// the user joined. The welcome card belongs to the day itself; coming back to
/// it a week on, a full welcome would be stale, but the date is still worth
/// marking. It sits on the page, like `MyDayTimelineMissingRow`, not on a card.
///
/// It still opens Getting Started — for the month the date strip reaches back,
/// it is a second way in that does not depend on remembering Settings.
struct MyDayJoinedRow: View {
    let onGettingStarted: () -> Void

    var body: some View {
        Button(action: onGettingStarted) {
            HStack(spacing: 10) {
                Image(systemName: "sparkles")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.white)
                    .frame(width: 28, height: 28)
                    .background(Color.white.opacity(0.16))
                    .clipShape(Circle())
                VStack(alignment: .leading, spacing: 1) {
                    Text("You joined INTHEGYM")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.white)
                    Text("Day one")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.white.opacity(0.7))
                }
                Spacer(minLength: 0)
                Text("Getting started")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.white.opacity(0.8))
                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Color.white.opacity(0.6))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Color.white.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ZStack {
        Color.pageColor.ignoresSafeArea()
        MyDayJoinedRow(onGettingStarted: {})
            .padding(16)
    }
}
