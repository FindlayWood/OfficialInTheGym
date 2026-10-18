//
//  WelcomeCardButtonStyle.swift
//  LoginKit
//
//  Created by Findlay Wood on 18/10/2026.
//

import SwiftUI

/// Presses a welcome card down to 0.97, so the screen answers a touch rather than reading as
/// printed, and reports the press so the showcase can hold still under the finger — a miniature
/// changing beneath a thumb reads as the tap having done something.
struct WelcomeCardButtonStyle: ButtonStyle {

    var onPressChange: ((Bool) -> Void)?

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { _, isPressed in
                onPressChange?(isPressed)
            }
    }
}
