//
//  NavBarHidingHostingController.swift
//  MyDayKit
//
//  Created by Findlay Wood on 04/08/2026.
//

import SwiftUI
import UIKit

/// Hosts a screen with the system navigation bar hidden, so a full-screen
/// overlay can cover every pixel of it.
///
/// Used by `MyDayWorkoutSessionScreen` and `MyDayWorkoutTemplateDetailScreen`,
/// both of which present the set detail overlay from `.overlay { }` inside this
/// controller's view. A `UINavigationBar` is a sibling owned by the
/// `UINavigationController` — drawn above this view, so no amount of
/// `.ignoresSafeArea()` gets the dim over it, and the overlay is structurally
/// boxed in below a bar it cannot dim. Hiding the bar and drawing
/// `MyDayWorkoutNavBar` in SwiftUI instead is what frees the overlay. Mirrors
/// `MyDayBoundaryViewController`, which does the same for the MyDay home screen.
///
/// Nothing here is screen-specific — host any screen that needs the bar gone.
final class NavBarHidingHostingController<Content: View>: UIHostingController<Content>,
                                                            UIGestureRecognizerDelegate {

    private weak var previousPopGestureDelegate: UIGestureRecognizerDelegate?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)

        // Hiding the bar takes the swipe-from-edge pop with it. Leaving these
        // screens costs nothing — session progress persists after every set,
        // and the template screen is read-only — so the gesture has to keep
        // working, or it would feel like a trap the design specifically avoids.
        if let gesture = navigationController?.interactivePopGestureRecognizer {
            previousPopGestureDelegate = gesture.delegate
            gesture.delegate = self
            gesture.isEnabled = true
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Screens pushed on top of these use the standard bar (the session
        // summary, for one), so restore it on the way out rather than once at
        // teardown.
        navigationController?.setNavigationBarHidden(false, animated: animated)
        navigationController?.interactivePopGestureRecognizer?.delegate = previousPopGestureDelegate
    }

    // MARK: - UIGestureRecognizerDelegate

    /// Guards the swipe against firing at the stack root, which deadlocks the
    /// navigation controller.
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        (navigationController?.viewControllers.count ?? 0) > 1
    }
}
