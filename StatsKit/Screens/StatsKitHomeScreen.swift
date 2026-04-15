//
//  StatsKitHomeScreen.swift
//  StatsKit
//
//  Created by Findlay Wood on 19/03/2026.
//

import Combine
import SwiftUI

struct StatsKitHomeScreen: View {
    
    @ObservedObject var viewModel: StatsKitHomeScreenViewModel

    var body: some View {
        ScrollView {
            HomeScreenContent(
                totals: viewModel.totals,
                exercises: viewModel.exerciseStats,
                muscleGroups: viewModel.muscleGroups,
                onSeeAllExercises: {
                    viewModel.onSeeAllExercises?()
                },
                onACWRDetail: {
                    viewModel.onACWRDetail?(viewModel.totals)
                },
                onExerciseTapped: { exercise in
                    viewModel.onExerciseTapped?(exercise)
                },
                onBodyMetricsDetail: {
                    
                },
                onTrainingBalanceTapped: {
                    viewModel.onTrainingBalanceTapped?(viewModel.totals, viewModel.muscleGroups, viewModel.movementTypes)
                }
            )
            .padding()
        }
        .background {
            Color.black.opacity(0.3).ignoresSafeArea()
        }
        .navigationTitle("Stats")
        .task { await viewModel.load() }
    }
}

#Preview {
    StatsKitHomeScreen(
        viewModel: StatsKitHomeScreenViewModel(
            loader: MockDailyTotalsProvider(),
            exerciseStatsLoader: MockExerciseLoader(),
            exerciseLoader: PreviewExerciseLoader(),
            muscleGroupLoader: PreviewMuscleGroupsLoader(),
            movementTypeLoader: PreviewMovementTypesLoader(),
            exerciseDailyStatsLoader: MockExerciseDailyStatsProvider()
        )
    )
}

final class StatsKitHomeScreenViewModel: ObservableObject {
    
    @Published var isLoading: Bool = false
    @Published var totals: [DailyTotal] = []
    @Published var exerciseStats: [ExerciseStats] = []
    @Published var exercises: [Exercise] = []
    @Published var muscleGroups: [MuscleGroup] = []
    @Published var movementTypes: [MovementPattern] = []
    
    let loader: DailyTotalsProviding
    let exerciseStatsLoader: StatsKitExerciseLoader
    
    let exerciseLoader: ExerciseLoader
    let muscleGroupLoader: MuscleGroupsLoader
    let movementTypeLoader: MovementTypesLoader
    
    let exerciseDailyStatsLoader: ExerciseDailyStatsProviding
    
    var onSeeAllExercises: (() -> ())?
    var onACWRDetail: (([DailyTotal]) -> ())?
    var onExerciseTapped: ((ExerciseStats) -> ())?
    var onTrainingBalanceTapped: (([DailyTotal], [MuscleGroup], [MovementPattern]) -> ())?
    
    init(
        loader: DailyTotalsProviding,
        exerciseStatsLoader: StatsKitExerciseLoader,
        exerciseLoader: ExerciseLoader,
        muscleGroupLoader: MuscleGroupsLoader,
        movementTypeLoader: MovementTypesLoader,
        exerciseDailyStatsLoader: ExerciseDailyStatsProviding,
        onSeeAllExercises: (() -> ())? = nil,
        onACWRDetail: (([DailyTotal]) -> ())? = nil,
        onExerciseTapped: ((ExerciseStats) -> ())? = nil,
        onTrainingBalanceTapped: (([DailyTotal], [MuscleGroup], [MovementPattern]) -> ())? = nil
    ) {
        self.loader = loader
        self.exerciseStatsLoader = exerciseStatsLoader
        self.exerciseLoader = exerciseLoader
        self.muscleGroupLoader = muscleGroupLoader
        self.movementTypeLoader = movementTypeLoader
        self.exerciseDailyStatsLoader = exerciseDailyStatsLoader
        self.onSeeAllExercises = onSeeAllExercises
        self.onACWRDetail = onACWRDetail
        self.onExerciseTapped = onExerciseTapped
        self.onTrainingBalanceTapped = onTrainingBalanceTapped
    }
    
    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            totals = try await loader.fetchDailyTotals()
            exerciseStats = try await exerciseStatsLoader.load()
            exercises = try await exerciseLoader.loadAll()
            muscleGroups = try await muscleGroupLoader.loadAll()
            movementTypes = try await movementTypeLoader.loadAll()
        } catch {
            print(String(describing: error))
        }
    }
}
