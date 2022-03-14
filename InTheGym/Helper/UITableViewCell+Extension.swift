//
//  UITableViewCell+Extension.swift
//  InTheGym
//
//  Created by Findlay Wood on 11/03/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

extension UITableViewCell {
    
    func flash(to colour: UIColor) {
        UIView.animate(withDuration: 0.3) {
            self.contentView.backgroundColor = colour
        } completion: { _ in
            UIView.animate(withDuration: 0.3) {
                self.contentView.backgroundColor = .white
            }
        }
    }
}
