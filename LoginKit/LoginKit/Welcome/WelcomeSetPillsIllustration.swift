//
//  WelcomeSetPillsIllustration.swift
//  LoginKit
//
//  Created by Findlay Wood on 18/10/2026.
//

import SwiftUI

/// Two exercises' worth of set pills, in the shape the session screen draws them. Built, all six
/// are logged in `darkColor` with a check; building fills them one by one in reading order, each
/// check popping as it lands — a session from its first set to its last.
struct WelcomeSetPillsIllustration: View {

    let isBuilt: Bool

    var body: some View {
        VStack(spacing: 6) {
            ForEach(0..<2, id: \.self) { row in
                HStack(spacing: 6) {
                    ForEach(0..<3, id: \.self) { column in
                        let index = row * 3 + column
                        pill(isLogged: isBuilt)
                            .animation(
                                isBuilt
                                    ? .spring(response: 0.3, dampingFraction: 0.65).delay(Double(index) * 0.15)
                                    : .easeOut(duration: 0.2),
                                value: isBuilt
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
            .scaleEffect(isLogged ? 1 : 0.92)
    }
}

#Preview {
    WelcomeSetPillsIllustration(isBuilt: true)
}
