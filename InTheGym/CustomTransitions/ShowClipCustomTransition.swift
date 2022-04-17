//
//  ShowClipCustomTransition.swift
//  InTheGym
//
//  Created by Findlay Wood on 16/04/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

final class ShowClipCustomTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    // MARK: - Duration
    static let duration: TimeInterval = 0.3
    
    private let animationType: ClipAnimationType
    private let firstViewController: CustomAnimatingClipFromVC
    private let secondViewController: ViewClipViewController
    private var selectedCellImageViewSnapshot: UIView
    private let cellImageViewRect: CGRect
    

    
    // MARK: - Initializer
    init?(animationType: ClipAnimationType, firstViewController: CustomAnimatingClipFromVC, secondViewController: ViewClipViewController, selectedCellImageViewSnapshot: UIView) {
        self.animationType = animationType
        self.firstViewController = firstViewController
        self.secondViewController = secondViewController
        self.selectedCellImageViewSnapshot = selectedCellImageViewSnapshot
        
        guard let window = firstViewController.view.window ?? secondViewController.view.window,
              let selectedCell = firstViewController.selectedCell
        else {
            return nil
        }
        
        self.cellImageViewRect = selectedCell.thumbnailImageView.convert(selectedCell.thumbnailImageView.bounds, to: window)
    }

    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return Self.duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
 
        let containerView = transitionContext.containerView

        
        guard let toView = secondViewController.view
            else {
                transitionContext.completeTransition(false)
                return
        }

        containerView.addSubview(toView)

        guard let selectedCell = firstViewController.selectedCell,
              let window = firstViewController.view.window ?? secondViewController.view.window,
              let cellImageSnapshot = selectedCell.thumbnailImageView.snapshotView(afterScreenUpdates: true),
              let controllerImageSnapshot = secondViewController.display.thumbnailImageView.snapshotView(afterScreenUpdates: true),
              let closeButtonSnapshot = secondViewController.display.backButton.snapshotView(afterScreenUpdates: true)
            else {
                transitionContext.completeTransition(true)
                return
        }

        let isPresenting = animationType.isPresenting
        
        // B5 - 40
        let backgroundView: UIView
        let fadeView = UIView(frame: containerView.bounds)
        fadeView.backgroundColor = secondViewController.view.backgroundColor
        
        // B4 - 33
        if isPresenting {
            selectedCellImageViewSnapshot = cellImageSnapshot
            // B5 - 41
            backgroundView = UIView(frame: containerView.bounds)
            backgroundView.addSubview(fadeView)
            fadeView.alpha = 0
        } else {
            backgroundView = firstViewController.view.snapshotView(afterScreenUpdates: true) ?? fadeView
            backgroundView.addSubview(fadeView)
        } 

        // B3 - 23
        toView.alpha = 0
        
        // B3 - 24
        [backgroundView, selectedCellImageViewSnapshot, controllerImageSnapshot, closeButtonSnapshot].forEach { containerView.addSubview($0) }

        // B3 - 25
        let controllerImageViewRect = secondViewController.view.convert(secondViewController.view.bounds, to: window)
        
        let closeButtonRect = secondViewController.display.backButton.convert(secondViewController.display.backButton.bounds, to: window)

        // B3 - 26
        [selectedCellImageViewSnapshot, controllerImageSnapshot].forEach {
            $0.frame = isPresenting ? cellImageViewRect : controllerImageViewRect
            
            $0.layer.cornerRadius = isPresenting ? 8 : 0
            $0.layer.masksToBounds = true
        }
        
        // B4 - 36
        controllerImageSnapshot.alpha = isPresenting ? 0 : 1

        // B4 - 37
        selectedCellImageViewSnapshot.alpha = isPresenting ? 1 : 0
        
        // B7 - 56
        closeButtonSnapshot.frame = closeButtonRect
        closeButtonSnapshot.alpha = isPresenting ? 0 : 1
        
        // B3 - 27
        UIView.animateKeyframes(withDuration: Self.duration, delay: 0, options: .calculationModeCubic, animations: {

            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1) {
                // B3 - 28
                // B4 - 38
                self.selectedCellImageViewSnapshot.frame = isPresenting ? controllerImageViewRect : self.cellImageViewRect
                controllerImageSnapshot.frame = isPresenting ? controllerImageViewRect : self.cellImageViewRect
                
                // B5 - 43
                fadeView.alpha = isPresenting ? 1 : 0
                
                // B8 - 60
                [controllerImageSnapshot, self.selectedCellImageViewSnapshot].forEach {
                    $0.layer.cornerRadius = isPresenting ? 0 : 8
                }
            }

            // B4 - 39
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.6) {
                self.selectedCellImageViewSnapshot.alpha = isPresenting ? 0 : 1
                controllerImageSnapshot.alpha = isPresenting ? 1 : 0
            }
            // B7 - 57
            UIView.addKeyframe(withRelativeStartTime: isPresenting ? 0.7 : 0, relativeDuration: 0.3) {
                closeButtonSnapshot.alpha = isPresenting ? 1 : 0
            }
        }, completion: { _ in
            // B3 - 29
            // B4 - 39.1
            self.selectedCellImageViewSnapshot.removeFromSuperview()
            controllerImageSnapshot.removeFromSuperview()
            
            // B5 - 44
            backgroundView.removeFromSuperview()
            
            closeButtonSnapshot.removeFromSuperview()

            // B3 - 30
            toView.alpha = 1

            // B3 - 31
            transitionContext.completeTransition(true)
        })
    }

    
    
}


enum ClipAnimationType {
    case present
    case dismiss
    
    var isPresenting: Bool {
        return self == .present
    }
}

protocol CustomAnimatingClipFromVC: UIViewController {
    var selectedCell: ClipCollectionCell? { get }
    var selectedCellImageViewSnapshot: UIView? { get }
}

protocol ClipCollectionCell: UICollectionViewCell {
    var thumbnailImageView: UIImageView { get }
}
