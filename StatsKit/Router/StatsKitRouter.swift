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
    let exerciseStatsLoader: StatsKitExerciseLoader
    let recentExerciseLoader: StatsKitExerciseLoader
    let exerciseDailyStatsLoader: ExerciseDailyStatsProviding
    let exerciseLoader: ExerciseLoader
    let muscleGroupLoader: MuscleGroupsLoader
    let movementTypeLoader: MovementTypesLoader

    // MARK: - Init

    public init(
        navigationController: UINavigationController,
        dailyTotalLoader: DailyTotalsProviding,
        exerciseStatsLoader: StatsKitExerciseLoader,
        recentExerciseLoader: StatsKitExerciseLoader,
        exerciseDailyStatsLoader: ExerciseDailyStatsProviding,
        exerciseLoader: ExerciseLoader,
        muscleGroupLoader: MuscleGroupsLoader,
        movementTypeLoader: MovementTypesLoader
    ) {
        self.navigationController = navigationController
        self.dailyTotalLoader = dailyTotalLoader
        self.exerciseStatsLoader = exerciseStatsLoader
        self.recentExerciseLoader = recentExerciseLoader
        self.exerciseDailyStatsLoader = exerciseDailyStatsLoader
        self.exerciseLoader = exerciseLoader
        self.muscleGroupLoader = muscleGroupLoader
        self.movementTypeLoader = movementTypeLoader
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
                exerciseStatsLoader: recentExerciseLoader,
                exerciseLoader: exerciseLoader,
                muscleGroupLoader: muscleGroupLoader,
                movementTypeLoader: movementTypeLoader,
                exerciseDailyStatsLoader: exerciseDailyStatsLoader,
                onSeeAllExercises: { [weak self] in
                    self?.navigate(to: .allExercises)
                },
                onACWRDetail: { [weak self] totals in
                    self?.navigate(to: .acwrDetail(totals: totals))
                },
                onTrainingBalanceTapped: { [weak self] totals, groups, types in
                    self?.navigate(to: .trainingBalance(totals, groups, types))
                }
            )
            let display = StatsKitHomeScreen(viewModel: viewModel)
            let vc = StatsKitBoundaryViewController()
            vc.display = display
            vc.router = self
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
        case .acwrDetail(let totals):
            let vc = UIHostingController(
                rootView: ACWRDetailScreen(totals: totals)
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
    
    func navigate(to route: StatsKitRoutes) {
        let vc = viewController(for: route)
        navigationController.pushViewController(vc, animated: true)
    }
}
