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
        VStack(spacing: 0) {
            
            header
            
            ScrollView {
                HomeScreenContent(
                    totals: viewModel.totals,
                    exercises: viewModel.exerciseStats,
                    muscleGroups: viewModel.muscleGroups,
                    onSeeAllExercises: {
                        viewModel.onSeeAllExercises?()
                    },
                    onACWRDetail: { metric in
                        viewModel.onACWRDetail?(viewModel.totals, metric)
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
        }
        .background {
            Color.pageColor.ignoresSafeArea()
        }
        .task { await viewModel.load() }
    }
    
    // MARK: - Header
    
    private var header: some View {
        VStack(spacing: 0) {
            HStack(alignment: .lastTextBaseline, spacing: 6) {
                Text("Stats")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(Color.darkColor)

                // The paywall's "INTHEGYM pro" wordmark at the tab's scale. This screen is only
                // drawn unlocked (`StatsKitRootScreen`), so it never claims pro for someone without it.
                Text("pro")
                    .font(.system(size: 22, weight: .heavy))
                    .foregroundStyle(Color.premiumColor)
                    .accessibilityLabel("Pro")

                Spacer()
                
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background {
            Color(UIColor.systemBackground).ignoresSafeArea()
        }
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
    var onACWRDetail: (([DailyTotal], TrainingLoadMetric) -> ())?
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
        onACWRDetail: (([DailyTotal], TrainingLoadMetric) -> ())? = nil,
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
