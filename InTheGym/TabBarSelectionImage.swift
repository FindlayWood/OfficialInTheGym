//
//  TabBarSelectionImage.swift
//  InTheGym
//
//  Created by Findlay Wood on 10/01/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit


extension UIImage{
    func createSelectionIndicator(color: UIColor, size: CGSize, lineWidth: CGFloat) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(CGRect(x: 0, y: size.height - lineWidth, width: size.width, height: lineWidth))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}
