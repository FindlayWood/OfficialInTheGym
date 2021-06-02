//
//  FlashView.swift
//  InTheGym
//
//  Created by Findlay Wood on 27/05/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class FlashView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func setUpView() {
        backgroundColor = .black
        alpha = 0.2
        isUserInteractionEnabled = false
    }
}
