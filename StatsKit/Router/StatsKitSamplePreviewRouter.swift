//
//  StatsKitSamplePreviewRouter.swift
//  StatsKit
//
//  Created by Findlay Wood on 18/10/2026.
//

import SwiftUI
import UIKit

/// Pushes `StatsSamplePreviewScreen` onto a stack it does not own — LoginKit's, from the welcome
/// screen and from the end of the example workout. It needs no dependencies: everything on the
/// screen is sample data, and nothing is read or written.
///
/// The system bar is hidden and the screen draws `StatsSamplePreviewNavBar`, the example workout's
/// bar, so the welcome screen's three previews read as one flow.
public final class StatsKitSamplePreviewRouter {

    // MARK: - Navigation

    private weak var navigationController: UINavigationController?

    // MARK: - Init

    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    // MARK: - Root

    public func start() {
        let screen = StatsSamplePreviewScreen(onBack: { [weak navigationController] in
            navigationController?.popViewController(animated: true)
        })
        navigationController?.pushViewController(StatsSamplePreviewHostingController(rootView: screen), animated: true)
    }
}
