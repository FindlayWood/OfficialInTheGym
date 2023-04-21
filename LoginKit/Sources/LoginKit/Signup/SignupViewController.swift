//
//  SignupViewController.swift
//  
//
//  Created by Findlay-Personal on 03/04/2023.
//

import UIKit

class SignupViewController: UIViewController {
    
    var display: SignupView!
    
    var viewModel: SignupViewModel!
    
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
        navigationItem.title = "Signup"
        editNavBarColour(to: colour)
    }
}
