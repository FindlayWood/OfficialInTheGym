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
/// (`var router`). This one keeps the system navigation bar, which those hide.
///
/// `onWillAppear` is what re-checks pro (`PerformanceGateViewModel.refresh`):
/// coming back from the full-screen paywall makes the tab appear again.
final class PerformanceKitHostingController<Content: View>: UIHostingController<Content> {

    var router: PerformanceKitRouter?
    var onWillAppear: (() -> Void)?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        onWillAppear?()
    }
}
