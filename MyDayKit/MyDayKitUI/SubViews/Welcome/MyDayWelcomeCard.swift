//
//  MyDayWelcomeCard.swift
//  MyDayKit
//
//  Created by Findlay Wood on 19/10/2026.
//

import SwiftUI

/// The top of MyDay on the day someone signs up: a welcome, one line on how
/// every day here works, and a way into Getting Started.
///
/// Signup used to end on an empty day with nothing that said hello. **This is a
/// card on the page, not a step in front of it** — account creation cut its
/// welcome step for being a screen that only tells, and a pager here would be
/// the same thing again, straight after the paywall. Someone who knows what to
/// do scrolls past it; the timeline under it is already the guide, so the card
/// only names it.
///
/// It changes its line once anything is trained, so it reads as day one going
/// well rather than repeating an instruction already followed.
struct MyDayWelcomeCard: View {
    let firstName: String?
    let hasTrained: Bool
    let onGettingStarted: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.white)
                    .frame(width: 28, height: 28)
                    .background(Color.darkColor)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                Text("Day one")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.secondary)
                    .textCase(.uppercase)
                    .tracking(1.2)
            }

            Text(title)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(Color.primary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 12)

            Text(message)
                .font(.system(size: 14))
                .foregroundStyle(Color.secondary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 6)

            Button(action: onGettingStarted) {
                HStack(spacing: 6) {
                    Text("Getting started")
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .bold))
                }
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color.darkColor)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(Color.darkColor.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .buttonStyle(.plain)
            .padding(.top, 16)
        }
        .padding(16)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var title: String {
        if let firstName { return "Welcome to INTHEGYM, \(firstName)" }
        return "Welcome to INTHEGYM"
    }

    private var message: String {
        hasTrained
            ? "Your first training is on the board. Every day here runs the same way: check in, train, then rate it."
            : "Every day here runs the same way: check in, train, then rate how hard it was. Start with any of them below."
    }
}

#Preview {
    ZStack {
        Color.pageColor.ignoresSafeArea()
        MyDayWelcomeCard(firstName: "Findlay", hasTrained: false, onGettingStarted: {})
            .padding(16)
    }
}
