//
//  VerifyAccountViewController.swift
//  InTheGym
//
//  Created by Findlay-Personal on 07/04/2023.
//  Copyright © 2023 FindlayWood. All rights reserved.
//

import UIKit

class VerifyAccountViewController: UIViewController {
    
    var viewModel = VerifyAccountViewModel()
    
    var display: VerifyAccountView!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addDisplay()
    }
    
    // MARK: - Display
    func addDisplay() {
        display = .init(viewModel: viewModel)
        addSwiftUIView(display)
    }
}
