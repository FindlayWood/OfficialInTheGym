//
//  Color+Extension.swift
//  MyDayKit
//
//  Created by Findlay Wood on 25/04/2026.
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
    
    static let thirdColour = Color(hex: 0xF3F9FF)

    /// StatsKit's matte palette, copied here as the brand colours are — **keep the two in step**.
    /// The check-in and RPE cards and the date strip's markers were system `.orange` / `.purple`,
    /// with their score scales on system red / orange / yellow / blue / green. At full saturation
    /// beside `darkColor` those read as another app's alerts. These sit at a similar lightness,
    /// so no score stands out just by being brighter. Check-in is `matteGreen`, RPE `matteAmber`.
    static let matteGreen = Color(hex: 0x5E9C7C)
    static let matteAmber = Color(hex: 0xC49A5C)
    static let matteRed   = Color(hex: 0xB96B5E)
    static let matteBlue  = Color(hex: 0x6D8FB0)
    
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
