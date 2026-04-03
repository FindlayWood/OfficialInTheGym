//
//  StatsKitRouter.swift
//  StatsKit
//
//  Created by Findlay Wood on 19/03/2026.
//

import UIKit
import SwiftUI

public final class StatsKitRouter {

    // MARK: - Navigation

    let navigationController: UINavigationController

    // MARK: - Dependencies
    let dailyTotalLoader: DailyTotalsProviding
    let exerciseLoader: StatsKitExerciseLoader
    let recentExerciseLoader: StatsKitExerciseLoader
    let exerciseDailyStatsLoader: ExerciseDailyStatsProviding

    // MARK: - Init

    public init(
        navigationController: UINavigationController,
        dailyTotalLoader: DailyTotalsProviding,
        exerciseLoader: StatsKitExerciseLoader,
        recentExerciseLoader: StatsKitExerciseLoader,
        exerciseDailyStatsLoader: ExerciseDailyStatsProviding
    ) {
        self.navigationController = navigationController
        self.dailyTotalLoader = dailyTotalLoader
        self.exerciseLoader = exerciseLoader
        self.recentExerciseLoader = recentExerciseLoader
        self.exerciseDailyStatsLoader = exerciseDailyStatsLoader
    }

    // MARK: - Root

    public func start() {
        let rootVC = viewController(for: .home)
        navigationController.setViewControllers([rootVC], animated: false)
    }
    
    
    func viewController(for route: StatsKitRoutes) -> UIViewController {
        switch route {
        case .home:
            let viewModel = StatsKitHomeScreenViewModel(
                loader: dailyTotalLoader,
                exerciseLoader: recentExerciseLoader,
                onSeeAllExercises: { [weak self] in
                    self?.navigate(to: .allExercises)
                }
            )
            let display = StatsKitHomeScreen(viewModel: viewModel)
            let vc = StatsKitBoundaryViewController()
            vc.display = display
            vc.router = self
            return vc
        case .allExercises:
            let viewModel = ExerciseListScreenViewModel(
                loader: exerciseLoader,
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
        }
    }
    
    func navigate(to route: StatsKitRoutes) {
        let vc = viewController(for: route)
        navigationController.pushViewController(vc, animated: true)
    }
}
