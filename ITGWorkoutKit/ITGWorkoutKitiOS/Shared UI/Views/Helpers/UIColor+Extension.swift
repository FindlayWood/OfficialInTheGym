//
//  UIColor+Extension.swift
//  ITGWorkoutKitiOS
//
//  Created by Findlay Wood on 27/07/2024.
//

import UIKit

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int, alpha: CGFloat = 1.0) {
        self.init(
            red: CGFloat(red) / 255.0,
            green: CGFloat(green) / 255.0,
            blue: CGFloat(blue) / 255.0,
            alpha: alpha
        )
    }

    convenience init(hex: Int, alpha: CGFloat = 1.0) {
        self.init(
            red: (hex >> 16) & 0xFF,
            green: (hex >> 8) & 0xFF,
            blue: hex & 0xFF,
            alpha: alpha
        )
    }
    
    static let darkBlue = UIColor(hex: 0x1D486D)
    static let lightBlue = UIColor(hex: 0x4179BD)
    static let bone = UIColor(hex: 0xE0DDCF)
    static let offWhite = UIColor(hex: 0xF1F0EA)
    static let purpureux = UIColor(hex: 0xA833B9)
    
    static let oxfordBlue = UIColor(hex: 0x0D1F30)
    static let prussianBlue = UIColor(hex: 0x1B304B)
    static let onyx = UIColor(hex: 0x3D3D3D)
    static let outerSpace = UIColor(hex: 0x474747)
    
    static var loadingBackgroundColor: UIColor {
        UIColor { traits in
            traits.userInterfaceStyle == .light ? .offWhite : prussianBlue
        }
    }
    
    static var customTintColor: UIColor {
        UIColor { traits in
            traits.userInterfaceStyle == .light ? .lightBlue : offWhite
        }
    }
}
