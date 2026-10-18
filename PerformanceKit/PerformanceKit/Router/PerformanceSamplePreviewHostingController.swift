//
//  PerformanceSamplePreviewHostingController.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 18/10/2026.
//

import SwiftUI
import UIKit

/// Hosts the sample preview with the system bar hidden, so it can draw `PerformanceSamplePreviewNavBar` like the example
/// workout beside it. **A copy of MyDayKit's `NavBarHidingHostingController` — keep in step.**
///
/// Hiding the bar takes the swipe-from-edge pop with it, so this takes over the gesture's delegate
/// while showing and allows it whenever there is somewhere to go back to. The bar is restored on
/// the way out: LoginKit's screens expect it.
final class PerformanceSamplePreviewHostingController<Content: View>: UIHostingController<Content>, UIGestureRecognizerDelegate {

    private weak var previousPopGestureDelegate: UIGestureRecognizerDelegate?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        if let gesture = navigationController?.interactivePopGestureRecognizer {
            previousPopGestureDelegate = gesture.delegate
            gesture.delegate = self
            gesture.isEnabled = true
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        navigationController?.interactivePopGestureRecognizer?.delegate = previousPopGestureDelegate
    }

    // MARK: - UIGestureRecognizerDelegate

    /// Guards the swipe against firing at the stack root, which deadlocks the navigation controller.
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        (navigationController?.viewControllers.count ?? 0) > 1
    }
}
