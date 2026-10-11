//
//  Color+Extension.swift
//  LoginKit
//
//  Created by Findlay Wood on 09/08/2026.
//

import SwiftUI
import UIKit

extension Color {

    static let lightColor = Color(hex: 0x4179BD)

    /// The brand accent: selection, tints, icons, filled buttons and pills. **Adaptive** —
    /// `#1C496E` in light appearance, `lightColor` (`#4179BD`) in dark. Navy on a dark surface
    /// reads at about 2:1, under the 3:1 a control needs, so in dark mode the accent steps up to
    /// the other brand colour rather than to a new one. Light appearance is unchanged.
    /// **A page background never uses this** — see `pageColor`.
    static let darkColor = Color(light: Color(hex: 0x1C496E), dark: lightColor)

    /// The page MyDay, Discover and Stats sit on: the brand navy (`#1C496E`) in light appearance,
    /// `systemGroupedBackground` (black) in dark. A navy page was tried in dark mode and looked
    /// wrong, so dark mode uses the standard iOS grouped surfaces and the brand shows through the
    /// accent instead. On this page, **cards are `secondarySystemGroupedBackground`** (white / dark
    /// grey) and wells inside a card are `tertiarySystemGroupedBackground`. A `systemBackground`
    /// card is black in dark mode, so it disappears into the page.
    /// **Pages use `pageColor`; controls use `darkColor`.**
    static let pageColor = Color(light: Color(hex: 0x1C496E), dark: Color(UIColor.systemGroupedBackground))

    /// A colour that follows the appearance (light / dark) of whatever draws it.
    init(light: Color, dark: Color) {
        self.init(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
    }

    /// create a colour using a hex code
    init(hex: Int, opacity: Double = 1.0) {
        let red = Double((hex & 0xff0000) >> 16) / 255.0
        let green = Double((hex & 0xff00) >> 8) / 255.0
        let blue = Double((hex & 0xff) >> 0) / 255.0
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
    }
}
