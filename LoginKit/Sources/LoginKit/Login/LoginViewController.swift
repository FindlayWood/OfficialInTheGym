//
//  LoginViewController.swift
//  
//
//  Created by Findlay-Personal on 03/04/2023.
//

import UIKit

class LoginViewController: UIViewController {
    
    var display: LoginView!
    
    var viewModel: LoginViewModel!
    
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
        navigationItem.title = "Login"
        editNavBarColour(to: colour)
    }
}
