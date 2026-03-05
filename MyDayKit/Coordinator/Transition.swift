//
//  Transition.swift
//  MyDayKit
//
//  Created by Findlay Wood on 07/02/2026.
//

import UIKit

final class ClipFromSwiftUITransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    // MARK: - Properties
    
    static let duration: TimeInterval = 0.3
    
    private let animationType: ClipAnimationType
    private let thumbnailSnapshot: UIView
    private let thumbnailFrame: CGRect
    private let destinationVC: ViewClipViewController
    
    // MARK: - Init
    
    init(
        animationType: ClipAnimationType,
        thumbnailSnapshot: UIView,
        thumbnailFrame: CGRect,
        destinationVC: ViewClipViewController
    ) {
        self.animationType = animationType
        self.thumbnailSnapshot = thumbnailSnapshot
        self.thumbnailFrame = thumbnailFrame
        self.destinationVC = destinationVC
    }
    
    // MARK: - UIViewControllerAnimatedTransitioning
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return Self.duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        
        guard let toView = transitionContext.view(forKey: .to),
              let fromView = transitionContext.view(forKey: .from)
        else {
            transitionContext.completeTransition(false)
            return
        }
        
        let isPresenting = animationType.isPresenting
        
        // Setup views
        let presentedView = isPresenting ? toView : fromView
        let dismissedView = isPresenting ? fromView : toView
        
        // Add the destination view to container
        if isPresenting {
            containerView.addSubview(toView)
            toView.frame = containerView.bounds
            toView.layoutIfNeeded()
            toView.alpha = 0
        }
        
        // Create snapshots
        guard let destinationImageSnapshot = destinationVC.display.thumbnailImageView.snapshotView(afterScreenUpdates: true)
        else {
            // Fallback to simple fade if snapshot fails
            toView.alpha = 1
            transitionContext.completeTransition(true)
            return
        }
        
        // Create background fade view
        let fadeView = UIView(frame: containerView.bounds)
        fadeView.backgroundColor = destinationVC.view.backgroundColor
        
        let backgroundView: UIView
        if isPresenting {
            backgroundView = UIView(frame: containerView.bounds)
            backgroundView.addSubview(fadeView)
            fadeView.alpha = 0
        } else {
            backgroundView = dismissedView.snapshotView(afterScreenUpdates: true) ?? fadeView
            backgroundView.addSubview(fadeView)
        }
        
        // Add views to container
        [backgroundView, thumbnailSnapshot, destinationImageSnapshot, toView].forEach {
            containerView.addSubview($0)
        }
        
        // Calculate frames
        guard let window = containerView.window else {
            transitionContext.completeTransition(false)
            return
        }
        
//        let destinationImageFrame = containerView.frame
        
        // Convert the thumbnail's frame to window coordinates
        let destinationImageFrame = destinationVC.display.thumbnailImageView.convert(
            destinationVC.display.thumbnailImageView.bounds,
            to: window
        )
        
        
        // Setup initial states
        thumbnailSnapshot.frame = isPresenting ? thumbnailFrame : destinationImageFrame
        thumbnailSnapshot.layer.cornerRadius = isPresenting ? 35 : 0
        thumbnailSnapshot.layer.masksToBounds = true
        thumbnailSnapshot.alpha = isPresenting ? 1 : 0
        
        destinationImageSnapshot.frame = isPresenting ? thumbnailFrame : destinationImageFrame
        destinationImageSnapshot.layer.cornerRadius = isPresenting ? 35 : 0
        destinationImageSnapshot.layer.masksToBounds = true
        destinationImageSnapshot.alpha = isPresenting ? 0 : 1
        
        // Animate
        UIView.animateKeyframes(
            withDuration: Self.duration,
            delay: 0,
            options: .calculationModeCubic,
            animations: {
                
                // Main frame animation
                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1) {
                    self.thumbnailSnapshot.frame = isPresenting ? destinationImageFrame : self.thumbnailFrame
                    destinationImageSnapshot.frame = isPresenting ? destinationImageFrame : self.thumbnailFrame
                    
                    fadeView.alpha = isPresenting ? 1 : 0
                    
                    self.thumbnailSnapshot.layer.cornerRadius = isPresenting ? 0 : 35
                    destinationImageSnapshot.layer.cornerRadius = isPresenting ? 0 : 35
                }
                
                // Crossfade between thumbnails
                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.6) {
                    self.thumbnailSnapshot.alpha = isPresenting ? 0 : 1
                    destinationImageSnapshot.alpha = isPresenting ? 1 : 0

                }
            },
            completion: { _ in
                // Cleanup
                self.thumbnailSnapshot.removeFromSuperview()
                destinationImageSnapshot.removeFromSuperview()
                backgroundView.removeFromSuperview()
                
                // Show the actual view
                presentedView.alpha = 1
                
                transitionContext.completeTransition(true)
            }
        )
    }
}



// MARK: - ClipModel

struct ClipModel {
    let clipID: String
    let videoURL: String
    let thumbnailURL: String?
    let userID: String
    let exerciseID: String
    let uploadedAt: Date
    let isPrivate: Bool
}

//
//  ClipFromSwiftUITransitionDelegate.swift
//  InTheGym
//
//  Created by Claude on 04/02/2026.
//

import UIKit

final class ClipFromSwiftUITransitionDelegate: NSObject, UIViewControllerTransitioningDelegate {
    
    private let thumbnail: UIImage
    private let thumbnailFrame: CGRect
    private let destinationVC: ViewClipViewController
    private var thumbnailSnapshot: UIView?
    
    init(thumbnail: UIImage, thumbnailFrame: CGRect, destinationVC: ViewClipViewController) {
        self.thumbnail = thumbnail
        self.thumbnailFrame = thumbnailFrame
        self.destinationVC = destinationVC
        super.init()
    }
    
    func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController,
        source: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        
        // Create snapshot from the thumbnail image
        let imageView = UIImageView(image: thumbnail)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.layer.masksToBounds = true
        thumbnailSnapshot = imageView
        
        return ClipFromSwiftUITransition(
            animationType: .present,
            thumbnailSnapshot: imageView,
            thumbnailFrame: thumbnailFrame,
            destinationVC: destinationVC
        )
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let snapshot = thumbnailSnapshot else { return nil }
        
        return ClipFromSwiftUITransition(
            animationType: .dismiss,
            thumbnailSnapshot: snapshot,
            thumbnailFrame: thumbnailFrame,
            destinationVC: destinationVC
        )
    }
}

// MARK: - Associated Object Key

private struct AssociatedKeys {
    static var transitionDelegate = "transitionDelegate"
}

//// MARK: - Coordinator Extension
//
//extension MyDayCoordinator {
//    
//    func presentClip(_ clip: ClipModel, thumbnail: UIImage, thumbnailFrame: CGRect) {
//        // Create ViewClipViewController
//        let viewClipVC = ViewClipViewController()
//        viewClipVC.clipModel = clip
//        
//        // Create custom transition
//        let transitionDelegate = ClipFromSwiftUITransitionDelegate(
//            thumbnail: thumbnail,
//            thumbnailFrame: thumbnailFrame,
//            destinationVC: viewClipVC
//        )
//        
//        viewClipVC.modalPresentationStyle = .custom
//        viewClipVC.transitioningDelegate = transitionDelegate
//        
//        // Keep the delegate alive
//        objc_setAssociatedObject(
//            viewClipVC,
//            &AssociatedKeys.transitionDelegate,
//            transitionDelegate,
//            .OBJC_ASSOCIATION_RETAIN_NONATOMIC
//        )
//        
//        navigationController.present(viewClipVC, animated: true)
//    }
//}

enum ClipAnimationType {
    case present
    case dismiss
    
    var isPresenting: Bool {
        return self == .present
    }
}
