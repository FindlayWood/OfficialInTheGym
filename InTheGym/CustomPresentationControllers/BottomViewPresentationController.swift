//
//  BottomViewPresentationController.swift
//  InTheGym
//
//  Created by Findlay Wood on 26/05/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class BottomViewPresentationController: UIPresentationController {
    
    private let blurEffectView: UIVisualEffectView!
    
    var viewHeightPrecentage: CGFloat = 0.25
    
    
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        let blurEffect = UIBlurEffect(style: .dark)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.isUserInteractionEnabled = true
        addBlurViewTap()
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        CGRect(origin: CGPoint(x: 0, y: Constants.screenSize.height - Constants.screenSize.height * viewHeightPrecentage),
               size: CGSize(width: Constants.screenSize.width, height: Constants.screenSize.height * viewHeightPrecentage))
    }
    
    override func presentationTransitionWillBegin() {
        blurEffectView.alpha = 0.0
        containerView?.addSubview(blurEffectView)
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { UIViewControllerTransitionCoordinatorContext in
            self.blurEffectView.alpha = 0.7
        }, completion: { UIViewControllerTransitionCoordinatorContext in
            
        })
    }
    
    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        containerView!.layer.cornerRadius = 20
        containerView!.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        containerView!.clipsToBounds = true
    }
    
    override func containerViewDidLayoutSubviews() {
        super.containerViewDidLayoutSubviews()
        presentedView?.frame = frameOfPresentedViewInContainerView
        blurEffectView.frame = containerView!.bounds
    }
    
    func addBlurViewTap() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(blurViewTapped))
        blurEffectView.addGestureRecognizer(tap)
    }
    
    @objc func blurViewTapped() {
        UIView.animate(withDuration: 0.3) {
            self.blurEffectView.alpha = 0.0
            self.presentedView?.frame = CGRect(x: 0, y: Constants.screenSize.height, width: Constants.screenSize.width, height: Constants.screenSize.height * self.viewHeightPrecentage)
        } completion: { _ in
            self.presentedViewController.dismiss(animated: false)
        }
    }
    
    override func dismissalTransitionWillBegin() {
        UIView.animate(withDuration: 0.3) {
            self.blurEffectView.alpha = 0.0
        }
    }
}
