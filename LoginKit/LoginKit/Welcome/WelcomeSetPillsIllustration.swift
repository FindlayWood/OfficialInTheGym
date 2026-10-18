//
//  WelcomeSetPillsIllustration.swift
//  LoginKit
//
//  Created by Findlay Wood on 18/10/2026.
//

import SwiftUI

/// Two exercises' worth of set pills, the logged ones in `darkColor` with a check — a session in
/// progress, in the shape the session screen draws it. The intro fills four in one by one; after
/// that each scene logs the next, with the check popping, and once all six are done the next scene
/// clears back to three and the session goes again.
struct WelcomeSetPillsIllustration: View {

    let isRevealed: Bool
    var scene: Int = 0

    /// How many pills are logged after each scene, in reading order. Scene 0 is the intro's four;
    /// after that it runs five, six, back to three (the reset), four, and round again.
    static func loggedCount(scene: Int) -> Int {
        guard scene > 0 else { return 4 }
        return [5, 6, 3, 4][(scene - 1) % 4]
    }

    var body: some View {
        let logged = isRevealed ? Self.loggedCount(scene: scene) : 0
        VStack(spacing: 6) {
            ForEach(0..<2, id: \.self) { row in
                HStack(spacing: 6) {
                    ForEach(0..<3, id: \.self) { column in
                        let index = row * 3 + column
                        pill(isLogged: index < logged)
                            // The intro staggers; a scene logs one pill, so it needs no stagger.
                            .animation(
                                scene == 0
                                    ? .easeOut(duration: 0.25).delay(Double(index) * 0.12)
                                    : .spring(response: 0.35, dampingFraction: 0.6),
                                value: index < logged
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
                    .symbolEffect(.bounce, value: isLogged)
                    .padding(.bottom, 4)
            }
    }
}

#Preview {
    WelcomeSetPillsIllustration(isRevealed: true)
}
