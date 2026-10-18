//
//  Color+Extension.swift
//  StatsKit
//
//  Created by Findlay Wood on 27/04/2026.
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

    /// The app's `premiumColour` colorset (`#79B49F`, the same in light and dark), which a
    /// framework cannot read from the app's asset catalog. **Keep in step with ProfileKit's,
    /// PerformanceKit's and LoginKit's copies.** A **semantic** colour marking pro, not an accent — here it is
    /// only the "pro" beside the tab title, the paywall's wordmark, so a subscriber sees the thing
    /// they bought — and the PRO tag on the sample preview shown before signup. Spend it anywhere
    /// else on this tab and it stops meaning pro.
    static let premiumColor = Color(hex: 0x79B49F)

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
