//
//  PlayerPerformanceSubviewViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 19/06/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

class PlayerPerformanceSubviewViewController: UIViewController {
    // MARK: - Properties
    var display = PlayerPerformanceSubviewView()
    // MARK: - View
    override func loadView() {
        view = display
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
