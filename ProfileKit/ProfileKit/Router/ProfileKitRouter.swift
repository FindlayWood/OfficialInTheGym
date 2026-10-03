//
//  ProfileKitRouter.swift
//  ProfileKit
//
//  Created by Findlay Wood on 03/10/2026.
//

import SwiftUI
import UIKit

/// The PROFILE tab's router, in the shape `StatsKitRouter` set: every
/// dependency through `public init`, `start()` sets the root, and
/// `viewController(for:)` is the one place a view model meets its screen.
///
/// The four `on…` closures reach screens that live in the app target and are
/// not ProfileKit's to build: the INTHEGYM pro paywall, the App Store's
/// subscription management, Performance Center, and the About page. The
/// composition root fills them before `start()`, following the child-coordinator
/// callback pattern. Performance Center in particular is a separate roadmap task,
/// reached from here only so it stays reachable. **None of its code is to be
/// deleted.**
public final class ProfileKitRouter {

    // MARK: - Navigation

    let navigationController: UINavigationController

    // MARK: - Dependencies

    let profileLoader: MyProfileLoader
    let photoLoader: ProfilePhotoLoader
    let subscription: ProfileSubscriptionService
    let signOutService: ProfileSignOutService
    let passwordReset: PasswordResetService
    let links: ProfileSettingsLinks

    // MARK: - Properties

    private(set) var rootViewController: UIViewController?

    public var onShowPaywall: (() -> Void)?
    public var onManageSubscription: (() -> Void)?
    public var onOpenPerformanceCenter: (() -> Void)?
    public var onOpenAbout: (() -> Void)?

    // MARK: - Init

    public init(
        navigationController: UINavigationController,
        profileLoader: MyProfileLoader,
        photoLoader: ProfilePhotoLoader,
        subscription: ProfileSubscriptionService,
        signOutService: ProfileSignOutService,
        passwordReset: PasswordResetService,
        links: ProfileSettingsLinks
    ) {
        self.navigationController = navigationController
        self.profileLoader = profileLoader
        self.photoLoader = photoLoader
        self.subscription = subscription
        self.signOutService = signOutService
        self.passwordReset = passwordReset
        self.links = links
    }

    // MARK: - Root

    @MainActor
    public func start() {
        // The pushed screens show the system bar, whose back chevron would
        // otherwise be system blue — the accent the brand rules exclude.
        navigationController.navigationBar.tintColor = UIColor(Color.darkColor)
        let rootVC = viewController(for: .myProfile)
        rootViewController = rootVC
        navigationController.setViewControllers([rootVC], animated: false)
    }
}

extension ProfileKitRouter {

    @MainActor
    func viewController(for route: ProfileKitRoutes) -> UIViewController {
        switch route {
        case .myProfile:
            let viewModel = MyProfileViewModel(
                profileLoader: profileLoader,
                photoLoader: photoLoader,
                subscription: subscription
            )
            viewModel.onOpenSettings = { [weak self] in self?.navigate(to: .settings) }
            let vc = ProfileKitBoundaryViewController()
            vc.display = MyProfileScreen(viewModel: viewModel)
            vc.router = self
            return vc

        case .settings:
            let viewModel = ProfileSettingsViewModel(
                subscription: subscription,
                signOutService: signOutService,
                passwordReset: passwordReset,
                links: links
            )
            viewModel.onShowPaywall = { [weak self] in self?.onShowPaywall?() }
            viewModel.onManageSubscription = { [weak self] in self?.onManageSubscription?() }
            viewModel.onOpenPerformanceCenter = { [weak self] in self?.onOpenPerformanceCenter?() }
            viewModel.onOpenAbout = { [weak self] in self?.onOpenAbout?() }
            let vc = UIHostingController(rootView: ProfileSettingsScreen(viewModel: viewModel))
            vc.hidesBottomBarWhenPushed = true
            return vc
        }
    }

    @MainActor
    func navigate(to route: ProfileKitRoutes) {
        navigationController.pushViewController(viewController(for: route), animated: true)
    }
}
