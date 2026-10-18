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
/// is written. The system bar stays, so the back chevron is the way out.
public final class PerformanceKitSamplePreviewRouter {

    // MARK: - Navigation

    private weak var navigationController: UINavigationController?

    // MARK: - Init

    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    // MARK: - Root

    public func start() {
        let vc = UIHostingController(rootView: PerformanceSamplePreviewScreen())
        vc.title = "Performance"
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.pushViewController(vc, animated: true)
    }
}
