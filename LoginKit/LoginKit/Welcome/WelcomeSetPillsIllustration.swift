//
//  WelcomeSetPillsIllustration.swift
//  LoginKit
//
//  Created by Findlay Wood on 18/10/2026.
//

import SwiftUI

/// Two exercises' worth of set pills, the logged ones in `darkColor` with a check — a session in
/// progress, in the shape the session screen draws it. On reveal they fill in one by one.
struct WelcomeSetPillsIllustration: View {

    let isRevealed: Bool

    /// Which of the six pills end up logged, row by row.
    private let logged = [[true, true, true], [true, false, false]]

    var body: some View {
        VStack(spacing: 6) {
            ForEach(0..<2, id: \.self) { row in
                HStack(spacing: 6) {
                    ForEach(0..<3, id: \.self) { column in
                        pill(isLogged: isRevealed && logged[row][column])
                            .animation(
                                .easeOut(duration: 0.25).delay(Double(row * 3 + column) * 0.12),
                                value: isRevealed
                            )
                    }
                }
            }
        }
    }

    private func pill(isLogged: Bool) -> some View {
        RoundedRectangle(cornerRadius: 6, style: .continuous)
            .fill(isLogged ? Color.darkColor : Color(UIColor.tertiarySystemFill))
            .frame(width: 24, height: 29)
            .overlay(alignment: .bottom) {
                Image(systemName: isLogged ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 8, weight: .semibold))
                    .foregroundStyle(isLogged ? Color.white : Color.secondary.opacity(0.5))
                    .padding(.bottom, 4)
            }
    }
}

#Preview {
    WelcomeSetPillsIllustration(isRevealed: true)
}
