//
//  Color+Extension.swift
//  StatsKit
//
//  Created by Findlay Wood on 27/04/2026.
//

import SwiftUI

extension Color {

    static let lightColor = Color(hex: 0x4179BD)
    static let darkColor = Color(hex: 0x1C496E)

    // MARK: - Matte palette
    /// The semantic colours the stats screens signal with — training zones, and
    /// the acute/chronic series that sit beside them.
    ///
    /// **Deliberately desaturated, and deliberately not the system colours.**
    /// `.red` / `.orange` / `.green` are tuned to shout: at full saturation
    /// beside `darkColor`, which is a deep muted navy, they read as alerts
    /// borrowed from another app rather than part of this one. These sit at a
    /// similar lightness to each other so no zone grabs the eye purely by being
    /// brighter than its neighbours — a caution should stand out because of
    /// *where the marker is*, not because orange is louder than green.
    ///
    /// Mid-tone by design, so each holds up on `systemBackground` in both light
    /// and dark appearance without a second variant.
    static let matteGreen = Color(hex: 0x5E9C7C)
    static let matteAmber = Color(hex: 0xC49A5C)
    static let matteRed   = Color(hex: 0xB96B5E)
    static let matteBlue  = Color(hex: 0x6D8FB0)
    static let mattePlum  = Color(hex: 0x8B7BA8)

    /// create a colour using a hex code
    init(hex: Int, opacity: Double = 1.0) {
        let red = Double((hex & 0xff0000) >> 16) / 255.0
        let green = Double((hex & 0xff00) >> 8) / 255.0
        let blue = Double((hex & 0xff) >> 0) / 255.0
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
    }
}
