//
//  PerformanceKitHostingController.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import SwiftUI
import UIKit

/// The PERFORMANCE tab's root: a `UIHostingController` that keeps its router
/// alive and says when it appears.
///
/// Nothing else holds `PerformanceKitRouter` once the composition root returns.
/// Every closure the router hands out captures it weakly, so without this the
/// router is released straight after `start()` and every tap does nothing. The
/// other frameworks' boundary view controllers hold theirs the same way
/// (`var router`).
///
/// `onWillAppear` is what re-checks pro (`PerformanceGateViewModel.refresh`):
/// coming back from the full-screen paywall makes the tab appear again.
///
/// It hides the system navigation bar while the root is showing and restores it
/// as anything is pushed, exactly as `StatsKitBoundaryViewController` does — the
/// root draws `PerformanceTabHeader` like every other tab, and the pushed test
/// screens keep the system bar and its back chevron.
final class PerformanceKitHostingController<Content: View>: UIHostingController<Content> {

    var router: PerformanceKitRouter?
    var onWillAppear: (() -> Void)?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        onWillAppear?()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}
