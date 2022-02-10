//
//  UIView+Extension.swift
//  InTheGym
//
//  Created by Findlay Wood on 02/02/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func addViewShadow(with colour: UIColor) {
        layer.shadowColor = colour.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 5.0)
        layer.shadowRadius = 6.0
        layer.shadowOpacity = 1.0
        layer.masksToBounds = false
    }
}
