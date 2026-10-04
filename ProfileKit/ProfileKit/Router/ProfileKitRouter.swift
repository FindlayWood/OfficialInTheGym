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
    let detailsWriter: ProfileDetailsWriter
    let photoUploader: ProfilePhotoUploader
    let bodyMeasurementsLoader: BodyMeasurementsLoader
    let bodyMeasurementsWriter: BodyMeasurementsWriter
    let weightLogLoader: WeightLogLoader
    let weightEntryWriter: WeightEntryWriter
    let weightEntryRemover: WeightEntryRemover
    let countsLoader: ProfileCountsLoader
    let followListLoader: FollowListLoader
    let summaryLoader: ProfileSummaryLoader
    let followStatusLoader: FollowStatusLoader
    let followWriter: FollowWriter
    let unfollower: Unfollower
    let followerRemover: FollowerRemover
    let links: ProfileSettingsLinks
    let currentUserId: String

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
        detailsWriter: ProfileDetailsWriter,
        photoUploader: ProfilePhotoUploader,
        bodyMeasurementsLoader: BodyMeasurementsLoader,
        bodyMeasurementsWriter: BodyMeasurementsWriter,
        weightLogLoader: WeightLogLoader,
        weightEntryWriter: WeightEntryWriter,
        weightEntryRemover: WeightEntryRemover,
        countsLoader: ProfileCountsLoader,
        followListLoader: FollowListLoader,
        summaryLoader: ProfileSummaryLoader,
        followStatusLoader: FollowStatusLoader,
        followWriter: FollowWriter,
        unfollower: Unfollower,
        followerRemover: FollowerRemover,
        links: ProfileSettingsLinks,
        currentUserId: String
    ) {
        self.navigationController = navigationController
        self.profileLoader = profileLoader
        self.photoLoader = photoLoader
        self.subscription = subscription
        self.signOutService = signOutService
        self.passwordReset = passwordReset
        self.detailsWriter = detailsWriter
        self.photoUploader = photoUploader
        self.bodyMeasurementsLoader = bodyMeasurementsLoader
        self.bodyMeasurementsWriter = bodyMeasurementsWriter
        self.weightLogLoader = weightLogLoader
        self.weightEntryWriter = weightEntryWriter
        self.weightEntryRemover = weightEntryRemover
        self.countsLoader = countsLoader
        self.followListLoader = followListLoader
        self.summaryLoader = summaryLoader
        self.followStatusLoader = followStatusLoader
        self.followWriter = followWriter
        self.unfollower = unfollower
        self.followerRemover = followerRemover
        self.links = links
        self.currentUserId = currentUserId
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
                countsLoader: countsLoader,
                subscription: subscription
            )
            viewModel.onOpenFollowList = { [weak self, weak viewModel] kind in
                guard let self, case .loaded(let header) = viewModel?.header else { return }
                self.navigate(to: .followList(kind, userId: header.userId))
            }
            viewModel.onOpenSettings = { [weak self] in self?.navigate(to: .settings) }
            viewModel.onEditProfile = { [weak self, weak viewModel] header, photo in
                self?.present(.editProfile(header: header, photo: photo, onSaved: {
                    Task { await viewModel?.load() }
                }))
            }
            let vc = ProfileKitBoundaryViewController()
            vc.display = MyProfileScreen(viewModel: viewModel)
            vc.router = self
            vc.onWillAppear = { [weak viewModel] in
                Task { await viewModel?.refreshCounts() }
            }
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
            viewModel.onOpenBodyMeasurements = { [weak self] in self?.navigate(to: .bodyMeasurements) }
            let vc = UIHostingController(rootView: ProfileSettingsScreen(viewModel: viewModel))
            vc.hidesBottomBarWhenPushed = true
            return vc

        case .bodyMeasurements:
            let viewModel = BodyMeasurementsViewModel(
                measurementsLoader: bodyMeasurementsLoader,
                measurementsWriter: bodyMeasurementsWriter,
                logLoader: weightLogLoader,
                entryWriter: weightEntryWriter,
                entryRemover: weightEntryRemover
            )
            let vc = UIHostingController(rootView: BodyMeasurementsScreen(viewModel: viewModel))
            vc.hidesBottomBarWhenPushed = true
            return vc

        case .followList(let kind, let userId):
            let viewModel = FollowListViewModel(
                kind: kind,
                userId: userId,
                currentUserId: currentUserId,
                listLoader: followListLoader,
                summaryLoader: summaryLoader,
                statusLoader: followStatusLoader,
                followWriter: followWriter,
                unfollower: unfollower,
                followerRemover: followerRemover
            )
            let vc = UIHostingController(rootView: FollowListScreen(viewModel: viewModel, photoLoader: photoLoader))
            vc.hidesBottomBarWhenPushed = true
            return vc

        case .editProfile(let header, let photo, let onSaved):
            let viewModel = EditProfileViewModel(
                header: header,
                photo: photo,
                detailsWriter: detailsWriter,
                photoUploader: photoUploader
            )
            viewModel.onSaved = onSaved
            let host = UIHostingController(rootView: EditProfileScreen(viewModel: viewModel))
            let modal = UINavigationController(rootViewController: host)
            viewModel.onFinished = { [weak modal] in modal?.dismiss(animated: true) }
            return modal
        }
    }

    @MainActor
    func present(_ route: ProfileKitRoutes) {
        navigationController.present(viewController(for: route), animated: true)
    }

    @MainActor
    func navigate(to route: ProfileKitRoutes) {
        navigationController.pushViewController(viewController(for: route), animated: true)
    }
}
