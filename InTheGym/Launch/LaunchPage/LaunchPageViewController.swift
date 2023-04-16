//
//  LaunchPageViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 26/11/2020.
//  Copyright © 2020 FindlayWood. All rights reserved.
//

import UIKit
import SCLAlertView
import Combine
import Firebase

class LaunchPageViewController: UIViewController {
    // MARK: - Outlets
    // MARK: - Properties
    var display: LaunchPageView!
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
