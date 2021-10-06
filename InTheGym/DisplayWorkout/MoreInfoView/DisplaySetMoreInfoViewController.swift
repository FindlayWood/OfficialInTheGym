//
//  DisplaySetMoreInfoViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 04/09/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class DisplaySetMoreInfoViewController: UIViewController {
    
    var display = DisplaySetMoreInfoView()
    
    var initialFrame: CGRect!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        navigationController?.setNavigationBarHidden(true, animated: false)
        navigationController?.delegate = self
        display.closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        display.frame = CGRect(x: 0, y: 0, width: Constants.screenSize.width, height: Constants.screenSize.height)
        view.addSubview(display)
    }
    
    @objc func close() {
        navigationController?.modalPresentationStyle = .custom
        navigationController?.dismiss(animated: true)
    }
}

extension DisplaySetMoreInfoViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        switch operation {
        case .push:
            return AnimationManager(animationDuration: 0.3, animationType: .present)
        case .pop:
            return AnimationManager(animationDuration: 0.3, animationType: .dismiss)
        default:
            return nil
        }
    }
}
