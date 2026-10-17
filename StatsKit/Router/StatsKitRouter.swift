//
//  StatsKitRouter.swift
//  StatsKit
//
//  Created by Findlay Wood on 19/03/2026.
//

import UIKit
import SwiftUI

/// The STATS tab's router.
///
/// **The whole tab is pro.** The root is `StatsKitRootScreen`, which shows the home with pro and
/// `StatsLockedScreen` without, re-checked every time it appears (`StatsGateViewModel`). Nothing
/// further in checks again: every other screen is reached from the home.
public final class StatsKitRouter {

    // MARK: - Navigation

    let navigationController: UINavigationController

    // MARK: - Dependencies
    let dailyTotalLoader: DailyTotalsProviding
    let exerciseStatsLoader: StatsKitExerciseLoader
    let recentExerciseLoader: StatsKitExerciseLoader
    let exerciseDailyStatsLoader: ExerciseDailyStatsProviding
    let exerciseLoader: ExerciseLoader
    let muscleGroupLoader: MuscleGroupsLoader
    let movementTypeLoader: MovementTypesLoader
    let proAccess: StatsProAccess

    // MARK: - Properties

    public var onShowPaywall: (() -> Void)?

    // MARK: - Init

    public init(
        navigationController: UINavigationController,
        dailyTotalLoader: DailyTotalsProviding,
        exerciseStatsLoader: StatsKitExerciseLoader,
        recentExerciseLoader: StatsKitExerciseLoader,
        exerciseDailyStatsLoader: ExerciseDailyStatsProviding,
        exerciseLoader: ExerciseLoader,
        muscleGroupLoader: MuscleGroupsLoader,
        movementTypeLoader: MovementTypesLoader,
        proAccess: StatsProAccess
    ) {
        self.navigationController = navigationController
        self.dailyTotalLoader = dailyTotalLoader
        self.exerciseStatsLoader = exerciseStatsLoader
        self.recentExerciseLoader = recentExerciseLoader
        self.exerciseDailyStatsLoader = exerciseDailyStatsLoader
        self.exerciseLoader = exerciseLoader
        self.muscleGroupLoader = muscleGroupLoader
        self.movementTypeLoader = movementTypeLoader
        self.proAccess = proAccess
    }

    // MARK: - Root

    @MainActor
    public func start() {
        let rootVC = viewController(for: .home)
        navigationController.setViewControllers([rootVC], animated: false)
    }
    
    
    @MainActor
    func viewController(for route: StatsKitRoutes) -> UIViewController {
        switch route {
        case .home:
            let viewModel = StatsKitHomeScreenViewModel(
                loader: dailyTotalLoader,
                exerciseStatsLoader: recentExerciseLoader,
                exerciseLoader: exerciseLoader,
                muscleGroupLoader: muscleGroupLoader,
                movementTypeLoader: movementTypeLoader,
                exerciseDailyStatsLoader: exerciseDailyStatsLoader,
                onSeeAllExercises: { [weak self] in
                    self?.navigate(to: .allExercises)
                },
                onACWRDetail: { [weak self] totals, metric in
                    self?.navigate(to: .acwrDetail(totals: totals, metric: metric))
                },
                onExerciseTapped: { [weak self] exercise in
                    self?.navigate(to: .exerciseDetail(exercise: exercise))
                },
                onTrainingBalanceTapped: { [weak self] totals, groups, types in
                    self?.navigate(to: .trainingBalance(totals, groups, types))
                }
            )
            let gate = StatsGateViewModel(proAccess: proAccess)
            gate.onShowPaywall = { [weak self] in self?.onShowPaywall?() }
            let vc = StatsKitBoundaryViewController()
            vc.display = StatsKitRootScreen(gate: gate, home: viewModel)
            vc.router = self
            // Coming back to the tab re-checks pro — including from the full-screen paywall.
            vc.onWillAppear = { [weak gate] in gate?.refresh() }
            return vc
        case .allExercises:
            let viewModel = ExerciseListScreenViewModel(
                loader: exerciseStatsLoader,
                onExerciseTapped: { [weak self] exercise in
                    self?.navigate(to: .exerciseDetail(exercise: exercise))
                }
            )
            let vc = UIHostingController(
                rootView: ExerciseListScreen(viewModel: viewModel)
            )
            vc.hidesBottomBarWhenPushed = true
            return vc
        case .exerciseDetail(let exercise):
            let viewModel = ExerciseDetailViewModel(
                exercise: exercise,
                provider: exerciseDailyStatsLoader
            )
            let vc = UIHostingController(
                rootView: ExerciseDetailScreen(viewModel: viewModel)
            )
            return vc
        case let .acwrDetail(totals, metric):
            let vc = UIHostingController(
                rootView: ACWRDetailScreen(totals: totals, metric: metric)
            )
            vc.hidesBottomBarWhenPushed = true
            return vc
            
        case let .trainingBalance(totals, groups, types):
            let vc = UIHostingController(
                rootView: TrainingBalanceScreen(
                    totals: totals,
                    muscleGroups: groups,
                    movementPatterns: types
                )
            )
            vc.hidesBottomBarWhenPushed = true
            return vc
        }
    }
    
    @MainActor
    func navigate(to route: StatsKitRoutes) {
        let vc = viewController(for: route)
        navigationController.pushViewController(vc, animated: true)
    }
}
