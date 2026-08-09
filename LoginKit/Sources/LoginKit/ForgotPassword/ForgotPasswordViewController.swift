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
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addDisplay()
        initNavBar()
    }
    
    // MARK: - Display
    func addDisplay() {
        display = .init(viewModel: viewModel)
        addSwiftUIView(display)
    }
    // MARK: - Nav Bar
    func initNavBar() {
        navigationItem.title = "Forgot Password"
        editNavBarColour()
        // This screen is presented modally in its own navigation controller, so it had no button to
        // leave by — only the sheet's swipe-down, which is not obvious once the keyboard is up.
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelTapped)
        )
    }

    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
}
