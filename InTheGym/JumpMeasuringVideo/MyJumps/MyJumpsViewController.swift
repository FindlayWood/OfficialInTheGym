//
//  MyJumpsViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 21/06/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

class MyJumpsViewController: UIViewController {
    // MARK: - Properties
    var display = MyJumpsView()
    // MARK: - View
    override func loadView() {
        view = display
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        initTargets()
    }
    // MARK: - Targets
    func initTargets() {
        display.newJumpButton.addTarget(self, action: #selector(recordNewJumpActions(_:)), for: .touchUpInside)
    }
}
// MARK: - Actions
private extension MyJumpsViewController {
    @objc func recordNewJumpActions(_ sender: UIButton) {
        let vc = JumpMeasuringViewController()
        vc.hidesBottomBarWhenPushed = true
        vc.modalPresentationStyle = .fullScreen
        navigationController?.present(vc, animated: true)
    }
}
