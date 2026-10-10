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
/// **The whole tab is pro.** The root is `PerformanceRootScreen`, which shows
/// the tests with pro and the locked screen without, re-checked each time it
/// appears (`PerformanceGateViewModel`). Nothing further in checks again.
///
/// `athleteId` is whose data the tests show, and `currentUserId` is who is
/// looking. They differ only when a coach opens an athlete's centre, and
/// recording is offered only when they are the same. Coach access is planned
/// for later (`PERFORMANCE_PLAN.md`), so the split stays.
///
/// **One router for every way in.** The tab starts it on the tab's stack. The
/// legacy callers (a coach's athlete page, the old "More" menu, the timeline)
/// start it on a navigation controller they present full screen, and set
/// `onDismiss`, which is what puts a Dismiss button on the root. The tab leaves
/// it nil, since a tab has nothing to dismiss to.
public final class PerformanceKitRouter {

    // MARK: - Navigation

    /// Weak, because the navigation controller holds this router through its
    /// root screen. A presented Performance Center would otherwise never be
    /// released after it is dismissed. Its owner (the tab bar, or whoever
    /// presented it) keeps it alive.
    private(set) weak var navigationController: UINavigationController?

    // MARK: - Dependencies

    let proAccess: PerformanceProAccess
    let jumpSessionsLoader: JumpTestSessionsLoader
    let jumpSessionWriter: JumpTestSessionWriter
    let bodyMassLoader: BodyMassLoader
    let currentUserId: String
    let athleteId: String

    // MARK: - Properties

    private(set) var rootViewController: UIViewController?

    public var onShowPaywall: (() -> Void)?
    /// Set only in emulator builds. It grants pro for the session; the locked
    /// screen shows its button only when this is set.
    public var onUnlockForTesting: (() -> Void)?
    /// Set before `start()` when the router is presented rather than a tab.
    public var onDismiss: (() -> Void)?

    // MARK: - Init

    public init(
        navigationController: UINavigationController,
        proAccess: PerformanceProAccess,
        jumpSessionsLoader: JumpTestSessionsLoader,
        jumpSessionWriter: JumpTestSessionWriter,
        bodyMassLoader: BodyMassLoader,
        currentUserId: String,
        athleteId: String
    ) {
        self.navigationController = navigationController
        self.proAccess = proAccess
        self.jumpSessionsLoader = jumpSessionsLoader
        self.jumpSessionWriter = jumpSessionWriter
        self.bodyMassLoader = bodyMassLoader
        self.currentUserId = currentUserId
        self.athleteId = athleteId
    }

    // MARK: - Root

    @MainActor
    public func start() {
        // The pushed screens show the system bar, whose back chevron would
        // otherwise be system blue, the accent the brand rules exclude.
        navigationController?.navigationBar.tintColor = UIColor(Color.darkColor)
        let rootVC = viewController(for: .home)
        rootViewController = rootVC
        navigationController?.setViewControllers([rootVC], animated: false)
    }
}

extension PerformanceKitRouter {

    @MainActor
    func viewController(for route: PerformanceKitRoutes) -> UIViewController {
        switch route {
        case .home:
            let gate = PerformanceGateViewModel(proAccess: proAccess)
            gate.onShowPaywall = { [weak self] in self?.onShowPaywall?() }
            if onUnlockForTesting != nil {
                gate.onUnlockForTesting = { [weak self] in self?.onUnlockForTesting?() }
            }
            let home = PerformanceDashboardViewModel(loader: jumpSessionsLoader, canRecord: currentUserId == athleteId)
            home.onSelectTool = { [weak self] in self?.open($0) }
            // The weekly check is a CMJ session (`FatigueCheck`).
            home.onStartCheck = { [weak self, weak home] in
                self?.present(.jumpTest(.cmj, onSaved: { home?.sessionSaved($0) }), from: self?.navigationController)
            }
            let vc = PerformanceKitHostingController(rootView: PerformanceRootScreen(gate: gate, home: home))
            vc.router = self
            // Coming back to the tab re-checks pro, and reloads the dashboard,
            // which is how a test saved from a test's own screen reaches it.
            // The first load is the screen's own `.task`.
            vc.onWillAppear = { [weak gate, weak home] in
                gate?.refresh()
                guard let home, gate?.isUnlocked == true, home.hasLoaded else { return }
                Task { await home.load() }
            }
            if onDismiss != nil {
                vc.navigationItem.leftBarButtonItem = UIBarButtonItem(
                    title: "Dismiss",
                    primaryAction: UIAction { [weak self] _ in self?.onDismiss?() }
                )
            }
            return vc

        case .jumpTestHome(let kind):
            let viewModel = JumpTestHomeViewModel(kind: kind, loader: jumpSessionsLoader, canRecord: currentUserId == athleteId)
            viewModel.onStartTest = { [weak self, weak viewModel] in
                self?.present(.jumpTest(kind, onSaved: { viewModel?.sessionSaved($0) }), from: self?.navigationController)
            }
            viewModel.onHistory = { [weak self] in self?.navigate(to: .jumpTestHistory(kind)) }
            viewModel.onHelp = { [weak self] in
                self?.present(.jumpInstructions(kind), from: self?.navigationController)
            }
            return UIHostingController(rootView: JumpTestHomeScreen(viewModel: viewModel))

        case .jumpTestHistory(let kind):
            let viewModel = JumpTestHistoryViewModel(kind: kind, loader: jumpSessionsLoader)
            return UIHostingController(rootView: JumpTestHistoryScreen(viewModel: viewModel))

        case .jumpInstructions(let kind):
            return UIHostingController(rootView: JumpInstructionsScreen(kind: kind))

        case .jumpTest(let kind, let onSaved):
            let viewModel = JumpTestSessionViewModel(kind: kind, writer: jumpSessionWriter, bodyMassLoader: bodyMassLoader)
            let navigationController = UINavigationController(
                rootViewController: UIHostingController(rootView: JumpTestSessionScreen(viewModel: viewModel))
            )
            navigationController.modalPresentationStyle = .fullScreen
            navigationController.navigationBar.tintColor = UIColor(Color.darkColor)
            viewModel.onRecordAttempt = { [weak self, weak navigationController, weak viewModel] in
                // Dismissing the session's navigation controller takes down
                // whatever is presented over it, the camera and the replay.
                let onMeasured: (JumpAttempt) -> Void = { attempt in
                    viewModel?.add(attempt)
                    navigationController?.dismiss(animated: true)
                }
                // The camera is checked first: opening it without one, or
                // without access, crashed.
                Task { @MainActor [weak self, weak navigationController] in
                    let availability = await JumpCameraAvailability.check()
                    let route: PerformanceKitRoutes = availability == .available
                        ? .jumpRecorder(kind, onMeasured: onMeasured)
                        : .jumpCameraUnavailable(availability, kind: kind, onMeasured: onMeasured)
                    self?.present(route, from: navigationController)
                }
            }
            viewModel.onFinished = { [weak navigationController] session in
                onSaved(session)
                navigationController?.presentingViewController?.dismiss(animated: true)
            }
            viewModel.onCancel = { [weak navigationController] in
                navigationController?.presentingViewController?.dismiss(animated: true)
            }
            return navigationController

        case .jumpRecorder(let kind, let onMeasured):
            let recorder = JumpMeasuringViewController()
            let navigationController = UINavigationController(rootViewController: recorder)
            navigationController.modalPresentationStyle = .fullScreen
            recorder.onRecorded = { [weak self, weak navigationController] url in
                self?.present(.jumpReplay(fileURL: url, kind: kind, onMeasured: onMeasured), from: navigationController, animated: false)
            }
            return navigationController

        case .jumpReplay(let fileURL, let kind, let onMeasured):
            let replay = ReplayJumpMeasureViewController(kind: kind)
            replay.fileURL = fileURL
            replay.onMeasured = { attempt in
                // The attempt is measured; the video is not kept.
                try? FileManager.default.removeItem(at: fileURL)
                onMeasured(attempt)
            }
            let navigationController = UINavigationController(rootViewController: replay)
            navigationController.modalPresentationStyle = .fullScreen
            return navigationController

        case .jumpCameraUnavailable(let availability, let kind, let onMeasured):
            weak var host: UIViewController?
            let screen = JumpCameraUnavailableScreen(
                availability: availability,
                kind: kind,
                onClose: { host?.dismiss(animated: true) },
                onSample: onMeasured
            )
            let vc = UIHostingController(rootView: screen)
            vc.modalPresentationStyle = .fullScreen
            host = vc
            return vc
        }
    }

    @MainActor
    func navigate(to route: PerformanceKitRoutes) {
        navigationController?.pushViewController(viewController(for: route), animated: true)
    }

    /// A jump test is a chain of presentations, session then camera then
    /// replay, each over the last. So a route is presented from whichever
    /// screen is on top, not always from this router's navigation controller.
    @MainActor
    func present(_ route: PerformanceKitRoutes, from presenter: UIViewController?, animated: Bool = true) {
        presenter?.present(viewController(for: route), animated: animated)
    }

    @MainActor
    func open(_ tool: PerformanceTool) {
        navigate(to: .jumpTestHome(tool.jumpTest))
    }
}
