//
//  WorkoutSessionHostingController.swift
//  MyDayKit
//
//  Created by Findlay Wood on 04/08/2026.
//

import SwiftUI
import UIKit

/// Hosts `MyDayWorkoutSessionScreen` with the navigation bar hidden.
///
/// The set detail overlay is presented from `.overlay { }` inside this
/// controller's view, and a `UINavigationBar` is a sibling owned by the
/// `UINavigationController` — drawn above it, so no amount of
/// `.ignoresSafeArea()` gets the dim over it. Hiding the bar and drawing
/// `WorkoutSessionNavBar` in SwiftUI is what lets the overlay cover the
/// whole screen. Mirrors `MyDayBoundaryViewController`, which does the same
/// for the MyDay home screen.
final class WorkoutSessionHostingController<Content: View>: UIHostingController<Content>,
                                                            UIGestureRecognizerDelegate {

    private weak var previousPopGestureDelegate: UIGestureRecognizerDelegate?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)

        // Hiding the bar takes the swipe-from-edge pop with it. This screen is
        // built so that leaving costs nothing — progress persists after every
        // set — so the gesture has to keep working, or it would feel like a
        // trap the design is specifically trying to avoid.
        if let gesture = navigationController?.interactivePopGestureRecognizer {
            previousPopGestureDelegate = gesture.delegate
            gesture.delegate = self
            gesture.isEnabled = true
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // The summary screen is pushed on top of this one and uses the standard
        // bar, so restore it on the way out rather than once at teardown.
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
