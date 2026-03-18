//
//  File.swift
//  
//
//  Created by Findlay-Personal on 14/05/2023.
//

import SwiftUI

enum Gradients {
    static var blueRaspberry: LinearGradient {
        LinearGradient(colors: [Color(UIColor.hexStringToUIColor(hex: "#00B4DB")),
                                Color(UIColor.hexStringToUIColor(hex: "#0083B0"))],
                       startPoint: .leading,
                       endPoint: .trailing)
    }
    static var terminal: LinearGradient {
        LinearGradient(colors: [Color(UIColor.hexStringToUIColor(hex: "#000000")),
                                Color(UIColor.hexStringToUIColor(hex: "#0f9b0f"))],
                       startPoint: .leading,
                       endPoint: .trailing)
    }
}
