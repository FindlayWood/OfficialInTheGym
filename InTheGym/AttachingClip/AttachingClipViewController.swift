//
//  AttachingClipViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 31/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class AttachingClipViewController: UIViewController {
    
    weak var coordinator: AttachingClipCoordinator?
    
    var display = AttachingClipView()
    
    private lazy var originPoint = originalFrame.origin
    private let originalFrame = CGRect(x: 0, y: Constants.screenSize.height - Constants.screenSize.height * 0.25, width: Constants.screenSize.width, height: Constants.screenSize.height * 0.25)


    override func viewDidLoad() {
        super.viewDidLoad()
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panGestureAction(_:)))
        self.view.addGestureRecognizer(pan)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        display.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        view.addSubview(display)
    }


}

// MARK: - Pan Gesture
extension AttachingClipViewController {
    @objc func panGestureAction(_ sender: UIPanGestureRecognizer) {

        let translation = sender.translation(in: self.view)
        if translation.y > 0 {
            self.view.frame = CGRect(x: 0, y: originPoint.y + translation.y, width: Constants.screenSize.width, height: Constants.screenSize.height * 0.25)
        }

        switch sender.state {
        case .ended:
            if translation.y > 100 {
                self.dismiss(animated: true)
            } else {
                UIView.animate(withDuration: 0.3) {
                    self.view.frame = self.originalFrame
                }
            }
        default:
            break
        }
    }
}
