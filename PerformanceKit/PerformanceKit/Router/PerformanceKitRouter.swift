//
//  PerformanceKitRouter.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//

import SwiftUI
import UIKit

/// The PERFORMANCE tab's router, in the shape `StatsKitRouter` set: every
/// dependency through `public init`, `start()` sets the root, and
/// `viewController(for:)` is the one place a view model meets its screen.
///
/// **Pro is checked here, each time a tool is opened** (see
/// `PerformanceProAccess`). The home screen itself is open to everyone, so a
/// user can see what pro would give them before being asked to pay for it.
///
/// **`onOpenLegacyTool` is temporary.** The tools are moving across from the
/// app target one at a time (`PERFORMANCE_PLAN.md`). Until a tool has moved,
/// selecting it calls back to the app, which pushes the legacy screens onto
/// this same navigation controller. Each tool that moves becomes a route here
/// and stops reaching that closure. Once all five have moved, the closure goes.
///
/// `athleteId` is whose data the tools show, and `currentUserId` is who is
/// looking. They differ only when a coach opens an athlete's centre.
public final class PerformanceKitRouter {

    // MARK: - Navigation

    let navigationController: UINavigationController

    // MARK: - Dependencies

    let proAccess: PerformanceProAccess
    let currentUserId: String
    let athleteId: String

    // MARK: - Properties

    private(set) var rootViewController: UIViewController?

    public var onShowPaywall: (() -> Void)?
    public var onOpenLegacyTool: ((PerformanceTool) -> Void)?

    // MARK: - Init

    public init(
        navigationController: UINavigationController,
        proAccess: PerformanceProAccess,
        currentUserId: String,
        athleteId: String
    ) {
        self.navigationController = navigationController
        self.proAccess = proAccess
        self.currentUserId = currentUserId
        self.athleteId = athleteId
    }

    // MARK: - Root

    @MainActor
    public func start() {
        // The pushed screens show the system bar, whose back chevron would
        // otherwise be system blue, the accent the brand rules exclude.
        navigationController.navigationBar.tintColor = UIColor(Color.darkColor)
        let rootVC = viewController(for: .home)
        rootViewController = rootVC
        navigationController.setViewControllers([rootVC], animated: false)
    }
}

extension PerformanceKitRouter {

    @MainActor
    func viewController(for route: PerformanceKitRoutes) -> UIViewController {
        switch route {
        case .home:
            let viewModel = PerformanceHomeViewModel(currentUserId: currentUserId, athleteId: athleteId)
            viewModel.onSelectTool = { [weak self] in self?.open($0) }
            let vc = PerformanceKitHostingController(rootView: PerformanceHomeScreen(viewModel: viewModel))
            vc.router = self
            return vc
        }
    }

    @MainActor
    func navigate(to route: PerformanceKitRoutes) {
        navigationController.pushViewController(viewController(for: route), animated: true)
    }

    @MainActor
    func open(_ tool: PerformanceTool) {
        guard proAccess.hasUnlockedPro else {
            onShowPaywall?()
            return
        }
        onOpenLegacyTool?(tool)
    }
}
