//
//  LastThreeScoresViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 18/03/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

class LastThreeScoresViewController: UIViewController {
    
    // MARK: - Properties
    var display = LastThreeScoresView()

    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        display.frame = view.bounds
        view.addSubview(display)
    }
}
