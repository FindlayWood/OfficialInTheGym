//
//  ForgotPasswordViewController.swift
//  
//
//  Created by Findlay-Personal on 04/04/2023.
//

import UIKit

class ForgotPasswordViewController: UIViewController {

    var display: ForgotPasswordView!
    
    var viewModel: ForgotPasswordViewModel!
    
    var colour: UIColor!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addDisplay()
        initNavBar()
    }
    
    // MARK: - Display
    func addDisplay() {
        display = .init(viewModel: viewModel, colour: colour)
        addSwiftUIView(display)
    }
    // MARK: - Nav Bar
    func initNavBar() {
        navigationItem.title = "Forgot Password"
        editNavBarColour(to: colour)
    }
}
