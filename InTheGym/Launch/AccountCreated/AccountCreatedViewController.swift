//
//  AccountCreatedViewController.swift
//  InTheGym
//
//  Created by Findlay-Personal on 15/04/2023.
//  Copyright © 2023 FindlayWood. All rights reserved.
//

import UIKit

class AccountCreatedViewController: UIViewController {
    
    var display: AccountCreatedView!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addDisplay()
    }
    // MARK: - Display
    func addDisplay() {
        display = .init()
        addSwiftUIView(display)
    }
}
