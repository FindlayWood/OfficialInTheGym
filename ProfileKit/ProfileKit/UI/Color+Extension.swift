//
//  Color+Extension.swift
//  ProfileKit
//
//  Created by Findlay Wood on 03/10/2026.
//
import SwiftUI

/// ProfileKit's copy of the brand colours. **Keep in step with the other
/// frameworks' `Color+Extension.swift`** — each module owns its own copy until
/// the shared UI framework exists, and the values must not drift apart.
extension Color {

    static let lightColor = Color(hex: 0x4179BD)
    static let darkColor = Color(hex: 0x1C496E)

    /// The app's `premiumColour` colorset (`#79B49F`, the same in light and
    /// dark), which a framework cannot read from the app's asset catalog. It is
    /// a **semantic** colour marking premium, like the category colours — not an
    /// accent. The app also has a purple `UIColor.premiumColour` literal; that is
    /// the documented app-wide conflict and is not settled here.
    static let premiumColor = Color(hex: 0x79B49F)

    /// The elite stamp's gold — `UIColor.goldColour` in the app target.
    static let eliteColor = Color(hex: 0xCFB33A)

    /// create a colour using a hex code
    init(hex: Int, opacity: Double = 1.0) {
        let red = Double((hex & 0xff0000) >> 16) / 255.0
        let green = Double((hex & 0xff00) >> 8) / 255.0
        let blue = Double((hex & 0xff) >> 0) / 255.0
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
    }
}
