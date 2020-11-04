//
//  ButtonExtension.swift
//  InTheGym
//
//  Created by Findlay Wood on 20/07/2019.
//  Copyright © 2019 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

extension UIButton {
    
    func pulsate(){
        
        let pulse = CASpringAnimation(keyPath: "transform.scale")
        pulse.duration = 0.5
        pulse.fromValue = 0.95
        pulse.toValue = 1.00
        pulse.autoreverses = true
        pulse.repeatCount = 1
        pulse.initialVelocity = 0.5
        pulse.damping = 1.0
        
        layer.add(pulse, forKey: nil)
    }
}
