//
//  MethodSelectionViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 13/04/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

class MethodSelectionViewController: UIViewController {

    // MARK: - Properties
    var display = MethodSelectionView()
    
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        initDisplay()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        display.frame = getFullViewableFrame()
        view.addSubview(display)
    }
    
    // MARK: - Display
    func initDisplay() {
        display.hofButton.addTarget(self, action: #selector(deepSelected(_:)), for: .touchUpInside)
        display.boxButton.addTarget(self, action: #selector(boxSelected(_:)), for: .touchUpInside)
    }
}

// MARK: - Actions
private extension MethodSelectionViewController {
    
    @objc func deepSelected(_ sender: UIButton) {
        let vc = HofBreathingViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func boxSelected(_ sender: UIButton) {
        let vc = BoxBreathingViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}
