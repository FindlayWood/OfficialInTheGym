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
                exercises: viewModel.exercises,
                onSeeAllExercises: {
                    viewModel.onSeeAllExercises?()
                },
                onACWRDetail: {
                    viewModel.onACWRDetail?()
                },
                onExerciseTapped: { exercise in
                    viewModel.onExerciseTapped?(exercise)
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
            exerciseLoader: MockExerciseLoader()
        )
    )
}

final class StatsKitHomeScreenViewModel: ObservableObject {
    
    @Published var isLoading: Bool = false
    @Published var totals: [DailyTotal] = []
    @Published var exercises: [ExerciseStats] = []
    
    let loader: DailyTotalsProviding
    let exerciseLoader: StatsKitExerciseLoader
    
    var onSeeAllExercises: (() -> ())?
    var onACWRDetail: (() -> ())?
    var onExerciseTapped: ((ExerciseStats) -> ())?
    
    init(
        loader: DailyTotalsProviding,
        exerciseLoader: StatsKitExerciseLoader,
        onSeeAllExercises: (() -> ())? = nil,
        onACWRDetail: (() -> ())? = nil,
        onExerciseTapped: ((ExerciseStats) -> ())? = nil
    ) {
        self.loader = loader
        self.exerciseLoader = exerciseLoader
        self.onSeeAllExercises = onSeeAllExercises
        self.onACWRDetail = onACWRDetail
        self.onExerciseTapped = onExerciseTapped
    }
    
    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            totals = try await loader.fetchDailyTotals()
            exercises = try await exerciseLoader.load()
        } catch {
            print(String(describing: error))
        }
    }
}
