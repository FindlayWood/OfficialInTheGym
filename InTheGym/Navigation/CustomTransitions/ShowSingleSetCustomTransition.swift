//
//  ShowSingleSetCustomTransition.swift
//  InTheGym
//
//  Created by Findlay Wood on 11/05/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

final class ShowSingleSetCustomTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    // MARK: - Duration
    static let duration: TimeInterval = 0.3
    
    private let animationType: AnimationType
    private let firstViewController: AnimatingSingleSet
    private let secondViewController: DisplaySingleSetViewController
    private var selectedCellImageViewSnapshot: UIView
    private let cellImageViewRect: CGRect
    private let cellLabelRect: CGRect
    

    
    // MARK: - Initializer
    init?(animationType: AnimationType, firstViewController: AnimatingSingleSet, secondViewController: DisplaySingleSetViewController, selectedCellImageViewSnapshot: UIView) {
        self.animationType = animationType
        self.firstViewController = firstViewController
        self.secondViewController = secondViewController
        self.selectedCellImageViewSnapshot = selectedCellImageViewSnapshot
        
        guard let window = firstViewController.view.window ?? secondViewController.view.window,
              let selectedCell = firstViewController.selectedSetCell
        else {
            return nil
        }
        
        self.cellImageViewRect = selectedCell.convert(selectedCell.bounds, to: window)
        self.cellLabelRect = selectedCell.setLabel.convert(selectedCell.setLabel.bounds, to: window)
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

        guard let selectedCell = firstViewController.selectedSetCell,
              let window = firstViewController.view.window ?? secondViewController.view.window,
              let cellImageSnapshot = selectedCell.snapshotView(afterScreenUpdates: true),
              let controllerImageSnapshot = secondViewController.display.snapshotView(afterScreenUpdates: true),
              let cellLabelSnapshot = secondViewController.display.setLabel.snapshotView(afterScreenUpdates: true)
            else {
                transitionContext.completeTransition(true)
                return
        }

        let isPresenting = animationType.isPresenting
        
        // B4 - 33
        if isPresenting {
            selectedCellImageViewSnapshot = cellImageSnapshot
        } else {
        }

        // B3 - 23
        toView.alpha = 0
        
        // B3 - 24
        [controllerImageSnapshot, selectedCellImageViewSnapshot].forEach { containerView.addSubview($0) }
//        [controllerImageSnapshot, cellLabelSnapshot].forEach { containerView.addSubview($0) }

        // B3 - 25
        let controllerImageViewRect = secondViewController.view.convert(secondViewController.view.bounds, to: window)
        let controllerLabelRect = secondViewController.display.setLabel.convert(secondViewController.display.setLabel.bounds, to: window)
        let controllerTestViewRect = secondViewController.display.setView.convert(secondViewController.display.setView.bounds, to: window)

        // B3 - 26
        [controllerImageSnapshot].forEach {
            $0.frame = isPresenting ? cellImageViewRect : controllerImageViewRect
            
            $0.layer.cornerRadius = isPresenting ? 10 : 0
            $0.layer.masksToBounds = true
        }
        
        // B4 - 36
        controllerImageSnapshot.alpha = isPresenting ? 1 : 1
        controllerImageSnapshot.layer.cornerRadius = 10

        // B4 - 37
//        selectedCellImageViewSnapshot.alpha = isPresenting ? 1 : 0
        
        selectedCellImageViewSnapshot.frame = isPresenting ? cellImageViewRect : controllerTestViewRect
        selectedCellImageViewSnapshot.layer.cornerRadius = 10
        selectedCellImageViewSnapshot.clipsToBounds = true
        cellLabelSnapshot.frame = isPresenting ? cellLabelRect : controllerLabelRect
        
        cellLabelSnapshot.alpha = isPresenting ? 1 : 1
        
        // B3 - 27
        UIView.animateKeyframes(withDuration: Self.duration, delay: 0, options: .calculationModeCubic, animations: {

            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1) {
                // B3 - 28
                // B4 - 38
                self.selectedCellImageViewSnapshot.frame = isPresenting ? controllerTestViewRect : self.cellImageViewRect
                controllerImageSnapshot.frame = isPresenting ? controllerImageViewRect : self.cellImageViewRect
//                cellLabelSnapshot.frame = isPresenting ? controllerLabelRect : self.cellLabelRect
                
                
                // B8 - 60
                [controllerImageSnapshot].forEach {
                    $0.layer.cornerRadius = isPresenting ? 0 : 10
                }
            }

            // B4 - 39
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.9) {
                self.selectedCellImageViewSnapshot.alpha = isPresenting ? 0 : 1
                controllerImageSnapshot.alpha = isPresenting ? 1 : 0
//                cellLabelSnapshot.alpha = isPresenting ? 1 : 0
            }
          
        }, completion: { _ in
            // B3 - 29
            // B4 - 39.1
            self.selectedCellImageViewSnapshot.removeFromSuperview()
            controllerImageSnapshot.removeFromSuperview()
//            cellLabelSnapshot.removeFromSuperview()

            // B3 - 30
            toView.alpha = 1

            // B3 - 31
            transitionContext.completeTransition(true)
        })
    }

    
    
}


enum AnimationType {
    case present
    case dismiss
    
    var isPresenting: Bool {
        return self == .present
    }
}

protocol AnimatingSingleSet: UIViewController {
    var selectedSetCell: MainWorkoutCollectionCell? { get }
    var selectedSetCellImageViewSnapshot: UIView? { get }
}

