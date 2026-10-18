//
//  PerformanceKitSamplePreviewRouter.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 18/10/2026.
//
import SwiftUI
import UIKit

/// Pushes `PerformanceSamplePreviewScreen` onto a stack it does not own — LoginKit's, from the
/// welcome screen. No dependencies: the sessions are `PreviewJumpTestSessionsLoader`'s and nothing
/// is written. The system bar is hidden and the screen draws `PerformanceSamplePreviewNavBar`, the
/// example workout's bar, so the welcome screen's three previews read as one flow.
public final class PerformanceKitSamplePreviewRouter {

    // MARK: - Navigation

    private weak var navigationController: UINavigationController?

    // MARK: - Init

    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    // MARK: - Root

    public func start() {
        let screen = PerformanceSamplePreviewScreen(onBack: { [weak navigationController] in
            navigationController?.popViewController(animated: true)
        })
        navigationController?.pushViewController(PerformanceSamplePreviewHostingController(rootView: screen), animated: true)
    }
}
