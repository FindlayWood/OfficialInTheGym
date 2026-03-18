//
//  UIView+TestHelpers.swift
//  InTheGymTests
//
//  Created by Findlay Wood on 12/06/2024.
//  Copyright © 2024 FindlayWood. All rights reserved.
//

import UIKit

extension UIView {
    func enforceLayoutCycle() {
          layoutIfNeeded()
          RunLoop.current.run(until: Date())
      }
}
