//
//  DisplaySetMoreInfoViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 04/09/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class DisplaySingleSetViewController: UIViewController {
    
    weak var coordinator: SingleSetCoordinator?
    
    var display = DisplaySingleSetView()

    // MARK: - View
    override func loadView() {
        view = display
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        display.dismissButton.addTarget(self, action: #selector(close), for: .touchUpInside)
    }
}
private extension DisplaySingleSetViewController {
    @objc func close() {
        coordinator?.dismissVC()
    }
}
