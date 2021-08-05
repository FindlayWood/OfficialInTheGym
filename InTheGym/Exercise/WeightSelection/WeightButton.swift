//
//  WeightButton.swift
//  InTheGym
//
//  Created by Findlay Wood on 16/06/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class WeightButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    required init?(coder: NSCoder) {
        fatalError()
    }
    func setUp() {
        backgroundColor = Constants.lightColour
        layer.cornerRadius = 10
        layer.borderWidth = 1.0
        layer.borderColor = Constants.darkColour.cgColor
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 5)
        layer.shadowRadius = 5
        layer.shadowOpacity = 1.0
        
        titleLabel?.font = Constants.font
        titleLabel?.adjustsFontSizeToFitWidth = true
        titleLabel?.minimumScaleFactor = 0.5
        setTitleColor(.white, for: .normal)
        
        heightAnchor.constraint(equalToConstant: 90).isActive = true
    }

}
