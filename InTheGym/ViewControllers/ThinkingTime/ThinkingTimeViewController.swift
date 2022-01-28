//
//  ThinkingTimeViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 27/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

class ThinkingTimeViewController: UIViewController {
    
    // MARK: - Properties
    var display = ThinkingTimeView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .offWhiteColour
        actions()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        display.frame = getViewableFrameWithBottomSafeArea()
        view.addSubview(display)
    }

    // MARK: - Button Actions
    func actions() {
        display.dismissButton.addTarget(self, action: #selector(dismissButtonAction(_:)), for: .touchUpInside)
    }
    @objc func dismissButtonAction(_ sender: UIButton) {
        self.dismiss(animated: true)
    }

}
