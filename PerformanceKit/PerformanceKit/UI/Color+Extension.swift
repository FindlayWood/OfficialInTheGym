//
//  Color+Extension.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import SwiftUI

/// PerformanceKit's copy of the brand colours. **Keep in step with the other
/// frameworks' `Color+Extension.swift`.** Each module owns its own copy until
/// the shared UI framework exists, and the values must not drift apart.
extension Color {

    static let lightColor = Color(hex: 0x4179BD)
    static let darkColor = Color(hex: 0x1C496E)

    /// The matte zone colours, StatsKit's values. **Keep in step with
    /// StatsKit's `Color+Extension.swift`.** Full-saturation system red, orange
    /// and green read as alerts beside `darkColor`; these sit at a similar
    /// lightness so no zone shouts louder than its meaning. `FatigueZone.color`
    /// owns the mapping, this file the values.
    static let matteGreen = Color(hex: 0x5E9C7C)
    static let matteAmber = Color(hex: 0xC49A5C)
    static let matteRed = Color(hex: 0xB96B5E)

    /// create a colour using a hex code
    init(hex: Int, opacity: Double = 1.0) {
        let red = Double((hex & 0xff0000) >> 16) / 255.0
        let green = Double((hex & 0xff00) >> 8) / 255.0
        let blue = Double((hex & 0xff) >> 0) / 255.0
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
    }
}
