//
//  File.swift
//  
//
//  Created by Findlay-Personal on 14/05/2023.
//

import UIKit

extension UIColor {
    static let darkColour = #colorLiteral(red: 0.1119553968, green: 0.2873651087, blue: 0.4327741265, alpha: 1)
    static let lightColour = #colorLiteral(red: 0.2555676699, green: 0.4766997099, blue: 0.7423972487, alpha: 1)
    static let offWhiteColour = #colorLiteral(red: 0.9176470588, green: 0.9254901961, blue: 0.9254901961, alpha: 1)
    static let babyBlue = #colorLiteral(red: 0.7490196078, green: 0.8431372549, blue: 0.9294117647, alpha: 1)
    static let thirdColour = #colorLiteral(red: 0.9529411765, green: 0.9803921569, blue: 1, alpha: 1)
    static let goldColour = #colorLiteral(red: 0.8117647059, green: 0.7019607843, blue: 0.2274509804, alpha: 1)
    static let completedColour = #colorLiteral(red: 0.00234289733, green: 0.8251151509, blue: 0.003635218529, alpha: 1)
    static let liveColour = #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1)
    static let notStartedColour = #colorLiteral(red: 0.8643916561, green: 0.1293050488, blue: 0.007468156787, alpha: 1)
    static let premiumColour = #colorLiteral(red: 0.4470588235, green: 0.03529411765, blue: 0.7176470588, alpha: 1)
    
    static func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if ((cString.count) != 6) {
            return UIColor.gray
        }

        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}

