//
//  UILabel+Extension.swift
//  InTheGym
//
//  Created by Findlay Wood on 09/09/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

extension UILabel {
    func increment() {
        guard let labelText = self.text else {return}
        guard var value = Int(labelText) else {return}
        value += 1
        self.text = value.description
    }
}
