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
    func addViewTopShadow(with colour: UIColor) {
        layer.shadowColor = colour.cgColor
        layer.shadowOffset = CGSize(width: 0, height: -5.0)
        layer.shadowRadius = 6.0
        layer.shadowOpacity = 1.0
        layer.masksToBounds = false
    }
    func addFullConstraint(to subview: UIView, withConstant constant: CGFloat = 0) {
        NSLayoutConstraint.activate([
            subview.topAnchor.constraint(equalTo: topAnchor, constant: constant),
            subview.leadingAnchor.constraint(equalTo: leadingAnchor, constant: constant),
            subview.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -constant),
            subview.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -constant)
        ])
    }
}
