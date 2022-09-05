//
//  PlayerDetailButtonSubviewViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 19/06/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

class PlayerDetailButtonSubviewViewController: UIViewController {
    // MARK: - Properties
    var display = PlayerDetailButtonSubviewView()
    // MARK: - View
    override func loadView() {
        view = display
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
