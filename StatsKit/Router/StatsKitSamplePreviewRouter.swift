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
/// The bar is made opaque `systemBackground` on this screen only. The page is `pageColor` — navy
/// in light — and a transparent bar over it would put the navy title and back chevron on navy.
public final class StatsKitSamplePreviewRouter {

    // MARK: - Navigation

    private weak var navigationController: UINavigationController?

    // MARK: - Init

    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    // MARK: - Root

    public func start() {
        let vc = UIHostingController(rootView: StatsSamplePreviewScreen())
        vc.title = "Stats"

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground
        appearance.titleTextAttributes = [.foregroundColor: UIColor(Color.darkColor)]
        vc.navigationItem.standardAppearance = appearance
        vc.navigationItem.scrollEdgeAppearance = appearance

        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.pushViewController(vc, animated: true)
    }
}
