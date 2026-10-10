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
///
/// **One router for every way in.** The tab starts it on the tab's stack. The
/// legacy callers (a coach's athlete page, the old "More" menu, the timeline)
/// start it on a navigation controller they present full screen, and set
/// `onDismiss`, which is what puts a Dismiss button on the home screen. The tab
/// leaves it nil, since a tab has nothing to dismiss to.
public final class PerformanceKitRouter {

    // MARK: - Navigation

    /// Weak, because the navigation controller holds this router through its
    /// root screen. A presented Performance Center would otherwise never be
    /// released after it is dismissed. Its owner (the tab bar, or whoever
    /// presented it) keeps it alive.
    private(set) weak var navigationController: UINavigationController?

    // MARK: - Dependencies

    let proAccess: PerformanceProAccess
    let journalLoader: JournalEntriesLoader
    let journalWriter: JournalEntryWriter
    let maxJumpLoader: MaxVerticalJumpLoader
    let jumpHistoryLoader: VerticalJumpHistoryLoader
    let jumpWriter: VerticalJumpWriter
    let trackedSessionsLoader: TrackedSessionsLoader
    let trackedSessionWriter: TrackedSessionWriter
    let workloadsLoader: WorkloadsLoader
    let workloadWriter: WorkloadWriter
    let wellnessLoader: WellnessSnapshotLoader
    let cmjLoader: CMJSnapshotLoader
    let currentUserId: String
    let athleteId: String

    // MARK: - Properties

    private(set) var rootViewController: UIViewController?

    public var onShowPaywall: (() -> Void)?
    public var onOpenLegacyTool: ((PerformanceTool) -> Void)?
    /// Set before `start()` when the router is presented rather than a tab.
    public var onDismiss: (() -> Void)?

    // MARK: - Init

    public init(
        navigationController: UINavigationController,
        proAccess: PerformanceProAccess,
        journalLoader: JournalEntriesLoader,
        journalWriter: JournalEntryWriter,
        maxJumpLoader: MaxVerticalJumpLoader,
        jumpHistoryLoader: VerticalJumpHistoryLoader,
        jumpWriter: VerticalJumpWriter,
        trackedSessionsLoader: TrackedSessionsLoader,
        trackedSessionWriter: TrackedSessionWriter,
        workloadsLoader: WorkloadsLoader,
        workloadWriter: WorkloadWriter,
        wellnessLoader: WellnessSnapshotLoader,
        cmjLoader: CMJSnapshotLoader,
        currentUserId: String,
        athleteId: String
    ) {
        self.navigationController = navigationController
        self.proAccess = proAccess
        self.journalLoader = journalLoader
        self.journalWriter = journalWriter
        self.maxJumpLoader = maxJumpLoader
        self.jumpHistoryLoader = jumpHistoryLoader
        self.jumpWriter = jumpWriter
        self.trackedSessionsLoader = trackedSessionsLoader
        self.trackedSessionWriter = trackedSessionWriter
        self.workloadsLoader = workloadsLoader
        self.workloadWriter = workloadWriter
        self.wellnessLoader = wellnessLoader
        self.cmjLoader = cmjLoader
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
            let viewModel = PerformanceHomeViewModel(currentUserId: currentUserId, athleteId: athleteId)
            viewModel.onSelectTool = { [weak self] in self?.open($0) }
            let vc = PerformanceKitHostingController(rootView: PerformanceHomeScreen(viewModel: viewModel))
            vc.router = self
            if onDismiss != nil {
                vc.navigationItem.leftBarButtonItem = UIBarButtonItem(
                    title: "Dismiss",
                    primaryAction: UIAction { [weak self] _ in self?.onDismiss?() }
                )
            }
            return vc

        case .journal:
            let viewModel = JournalHomeViewModel(loader: journalLoader)
            let screen = JournalHomeScreen(viewModel: viewModel) { [journalWriter] in
                JournalEntryViewModel(writer: journalWriter)
            }
            return UIHostingController(rootView: screen)

        case .verticalJump:
            let viewModel = VerticalJumpHomeViewModel(loader: maxJumpLoader, canRecord: currentUserId == athleteId)
            viewModel.onRecordNewJump = { [weak self] max in
                self?.present(.jumpRecorder(max: max), from: self?.navigationController)
            }
            viewModel.onPreviousJumps = { [weak self] in self?.navigate(to: .previousJumps) }
            viewModel.onHelp = { [weak self] in
                self?.present(.jumpInstructions, from: self?.navigationController)
            }
            return UIHostingController(rootView: VerticalJumpHomeScreen(viewModel: viewModel))

        case .previousJumps:
            let viewModel = PreviousJumpsViewModel(loader: jumpHistoryLoader)
            return UIHostingController(rootView: PreviousJumpsScreen(viewModel: viewModel))

        case .jumpInstructions:
            return UIHostingController(rootView: JumpInstructionsScreen())

        case .jumpRecorder(let max):
            let recorder = JumpMeasuringViewController()
            let navigationController = UINavigationController(rootViewController: recorder)
            navigationController.modalPresentationStyle = .fullScreen
            recorder.onRecorded = { [weak self, weak navigationController] url in
                self?.present(.jumpReplay(fileURL: url, max: max), from: navigationController, animated: false)
            }
            return navigationController

        case .jumpReplay(let fileURL, let max):
            let replay = ReplayJumpMeasureViewController()
            replay.viewModel.fileURL = fileURL
            let navigationController = UINavigationController(rootViewController: replay)
            navigationController.modalPresentationStyle = .fullScreen
            replay.onHeightCalculated = { [weak self, weak navigationController] height in
                self?.present(.jumpResult(height: height, max: max), from: navigationController)
            }
            return navigationController

        case .jumpResult(let height, let max):
            let viewModel = JumpResultsViewModel(height: height, max: max, writer: jumpWriter)
            let vc = UIHostingController(rootView: JumpResultsScreen(viewModel: viewModel))
            viewModel.onDismiss = { [weak vc] in vc?.dismiss(animated: true) }
            return vc

        case .tracker(let kind):
            let viewModel = TrackerHomeViewModel(kind: kind, loader: trackedSessionsLoader, canRecord: currentUserId == athleteId)
            viewModel.onSelectSession = { [weak self] in
                self?.navigate(to: .trackedSession($0, kind: kind))
            }
            let screen = TrackerHomeScreen(viewModel: viewModel) { [workloadsLoader, wellnessLoader, cmjLoader, trackedSessionWriter, workloadWriter] in
                NewTrackedSessionViewModel(
                    kind: kind,
                    workloadsLoader: workloadsLoader,
                    wellnessLoader: wellnessLoader,
                    cmjLoader: cmjLoader,
                    sessionWriter: trackedSessionWriter,
                    workloadWriter: workloadWriter
                )
            }
            return UIHostingController(rootView: screen)

        case .trackedSession(let session, let kind):
            return UIHostingController(rootView: TrackedSessionDetailScreen(session: session, title: kind.detailTitle))
        }
    }

    @MainActor
    func navigate(to route: PerformanceKitRoutes) {
        navigationController?.pushViewController(viewController(for: route), animated: true)
    }

    /// Vertical Jump's flow is a chain of presentations, camera then replay
    /// then result, each over the last. So a route is presented from whichever
    /// screen is on top, not always from this router's navigation controller.
    @MainActor
    func present(_ route: PerformanceKitRoutes, from presenter: UIViewController?, animated: Bool = true) {
        presenter?.present(viewController(for: route), animated: animated)
    }

    @MainActor
    func open(_ tool: PerformanceTool) {
        guard proAccess.hasUnlockedPro else {
            onShowPaywall?()
            return
        }
        switch tool {
        case .journal:
            navigate(to: .journal)
        case .verticalJump:
            navigate(to: .verticalJump)
        case .matchTracker:
            navigate(to: .tracker(.match))
        case .practiceTracker:
            navigate(to: .tracker(.practice))
        case .workload:
            onOpenLegacyTool?(tool)
        }
    }
}
