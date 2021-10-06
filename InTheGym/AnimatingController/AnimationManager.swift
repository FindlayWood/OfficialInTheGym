//
//  AnimationManager.swift
//  InTheGym
//
//  Created by Findlay Wood on 04/09/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

final class AnimationManager: NSObject {
    
    // MARK: - Variables
    private let animationDuration: Double
    private let animationType: AnimationType
    
    // MARK: - Initializer
    init(animationDuration: Double, animationType: AnimationType) {
        self.animationDuration = animationDuration
        self.animationType = animationType
    }
}
extension AnimationManager: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return TimeInterval(exactly: animationDuration) ?? 0
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let toViewController = transitionContext.viewController(forKey: .to),
            let fromViewController = transitionContext.viewController(forKey: .from)
        else {
            transitionContext.completeTransition(false)
            return
        }
        
        switch animationType {
        case .present:
            presentAnimation(
                transitionContext: transitionContext,
                fromView: fromViewController,
                toView: toViewController
                )
        case .dismiss:
            dismissAnimation(
                transitionContext: transitionContext,
                fromView: fromViewController,
                toView: toViewController
            )
        }
    }
}

extension AnimationManager {
    func presentAnimation(transitionContext: UIViewControllerContextTransitioning,
                          fromView: UIViewController,
                          toView: UIViewController) {
        
        let containerView = transitionContext.containerView
        
        guard let fromWorkoutVC = fromView as? DisplayWorkoutViewController else {return}
        guard let toSetMoreInfoVC = toView as? DisplaySetMoreInfoViewController else {return}
        
        let backgroundView = UIView()
        
        backgroundView.frame = toSetMoreInfoVC.initialFrame
        backgroundView.backgroundColor = .darkColour
        backgroundView.layer.cornerRadius = 10
        
        containerView.addSubview(fromWorkoutVC.view)
        containerView.addSubview(toSetMoreInfoVC.view)
        containerView.addSubview(backgroundView)
        
        fromWorkoutVC.view.isHidden = false
        toSetMoreInfoVC.view.isHidden = true
        
        let frameFinishingPosition: CGRect = CGRect(x: 0, y: 0, width: Constants.screenSize.width, height: Constants.screenSize.height)
        
        let animator = {
            UIViewPropertyAnimator(duration: self.animationDuration, curve: .easeOut) {
                backgroundView.frame = frameFinishingPosition
                
            }
        }()
    
        animator.addCompletion { _ in
            fromWorkoutVC.view.isHidden = false
            toSetMoreInfoVC.view.isHidden = false
            backgroundView.removeFromSuperview()
            
            transitionContext.completeTransition(true)
        }
        
        animator.startAnimation()
        
    }
}

extension AnimationManager {
    func dismissAnimation(transitionContext: UIViewControllerContextTransitioning,
                          fromView: UIViewController,
                          toView: UIViewController) {
        
        let containerView = transitionContext.containerView
        
        guard let fromWorkoutVC = toView as? DisplayWorkoutViewController else {return}
        guard let toSetMoreInfoVC = fromView as? DisplaySetMoreInfoViewController else {return}
        
        let backgroundView = UIView()
        
        backgroundView.frame = CGRect(x: 0, y: 0, width: Constants.screenSize.width, height: Constants.screenSize.height)
        backgroundView.backgroundColor = .darkColour
        backgroundView.layer.cornerRadius = 10
        
        containerView.addSubview(fromWorkoutVC.view)
        containerView.addSubview(toSetMoreInfoVC.view)
        containerView.addSubview(backgroundView)
        
        fromWorkoutVC.view.isHidden = false
        toSetMoreInfoVC.view.isHidden = true
        
        let frameFinishingPosition = toSetMoreInfoVC.initialFrame!
        
        let animator = {
            UIViewPropertyAnimator(duration: self.animationDuration, curve: .easeOut) {
                backgroundView.frame = frameFinishingPosition
                
            }
        }()
    
        animator.addCompletion { _ in
            fromWorkoutVC.view.isHidden = false
            toSetMoreInfoVC.view.isHidden = true
            backgroundView.removeFromSuperview()
            
            transitionContext.completeTransition(true)
        }
        
        animator.startAnimation()
        
    }
}

enum AnimationType {
    case present
    case dismiss
}
