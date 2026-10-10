//
//  UIColor+Brand.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import SwiftUI
import UIKit

/// The brand colours for PerformanceKit's UIKit screens, taken from
/// `Color+Extension.swift` so there is still only one copy of each value in
/// this module. The legacy jump screens read the app's `UIColor.darkColour` /
/// `.lightColour`, which a framework cannot see.
extension UIColor {
    static let darkColor = UIColor(Color.darkColor)
    static let lightColor = UIColor(Color.lightColor)
}
