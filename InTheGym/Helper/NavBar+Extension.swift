//
//  NavBar+Extension.swift
//  InTheGym
//
//  Created by Findlay Wood on 23/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

extension UIViewController {
    func editNavBarColour(to colour: UIColor) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        let textAttributes = [NSAttributedString.Key.foregroundColor: colour]
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes
        self.navigationController?.navigationBar.tintColor = colour
    }
}


