//
//  AccountCreationBoundaryViewController.swift
//  AccountCreationKit
//
//  Created by Findlay Wood on 09/08/2026.
//

import SwiftUI
import UIKit

class AccountCreationBoundaryViewController: UIViewController {

    var display: AccountCreationHomeScreen!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addDisplay()
    }

    // MARK: - Display
    func addDisplay() {
        addSwiftUIView(display)
    }
}
