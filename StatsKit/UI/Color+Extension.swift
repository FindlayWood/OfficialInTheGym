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
    
    /// create a colour using a hex code
    init(hex: Int, opacity: Double = 1.0) {
        let red = Double((hex & 0xff0000) >> 16) / 255.0
        let green = Double((hex & 0xff00) >> 8) / 255.0
        let blue = Double((hex & 0xff) >> 0) / 255.0
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
    }
}
