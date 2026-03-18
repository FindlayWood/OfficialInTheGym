//
//  AccountCreatedViewController.swift
//  InTheGym
//
//  Created by Findlay-Personal on 15/04/2023.
//  Copyright © 2023 FindlayWood. All rights reserved.
//

import UIKit

class AccountCreatedViewController: UIViewController {
    
    var display: AccountCreatedSubscriptionView!
    var viewModel: AccountCreatedViewModel!
    var baseFlow: BaseFlow?
    var user: Users!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addDisplay()
    }
    // MARK: - Display
    func addDisplay() {
        display = .init(viewModel: viewModel) { [weak self] in
            if self?.user.accountType == .coach {
                self?.baseFlow?.showLoggedInCoach()
            } else {
                self?.baseFlow?.showLoggedInPlayer()
            }
        }
        addSwiftUIView(display)
    }
}
