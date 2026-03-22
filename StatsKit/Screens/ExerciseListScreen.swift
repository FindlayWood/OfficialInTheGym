//
//  ExerciseListScreen.swift
//  StatsKit
//
//  Created by Findlay Wood on 22/03/2026.
//

import SwiftUI

// MARK: - ExerciseListScreen
struct ExerciseListScreen: View {

    @ObservedObject var viewModel: ExerciseListScreenViewModel

    @State private var searchText = ""

    private var filtered: [ExerciseStats] {
        let sorted = viewModel.exercises.sorted { $0.lastRecordDate > $1.lastRecordDate }
        guard !searchText.isEmpty else { return sorted }
        return sorted.filter {
            $0.exerciseName.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        Group {
            if viewModel.exercises.isEmpty {
                ContentUnavailableView(
                    "No exercises yet",
                    systemImage: "figure.strengthtraining.functional",
                    description: Text("Start logging workouts to see your exercises here.")
                )
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        if filtered.isEmpty && !searchText.isEmpty {
                            ContentUnavailableView.search(text: searchText)
                                .padding(.top, 40)
                        } else {
                            SectionContainer(
                                title: "\(filtered.count) exercise\(filtered.count == 1 ? "" : "s")"
                            ) {
                                ForEach(Array(filtered.enumerated()), id: \.element.id) { index, exercise in
                                    Button(action: { viewModel.onExerciseTapped?(exercise) }) {
                                        ExerciseRowContent(exercise: exercise)
                                    }
                                    .buttonStyle(.plain)

                                    if index < filtered.count - 1 {
                                        Divider()
                                            .padding(.horizontal, 16)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                .searchable(text: $searchText, prompt: "Search exercises")
            }
        }
        .navigationTitle("Exercises")
        .navigationBarTitleDisplayMode(.large)
        .task {
            await viewModel.loadExercises()
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        ExerciseListScreen(
            viewModel: ExerciseListScreenViewModel(loader: MockExerciseLoader())
        )
    }
}


import Combine

final class ExerciseListScreenViewModel: ObservableObject {
    @Published var exercises: [ExerciseStats] = []
    @Published var isLoading: Bool = false
    
    let loader: StatsKitExerciseLoader
    
    var onExerciseTapped: ((ExerciseStats) -> ())?
    
    init(
        loader: StatsKitExerciseLoader,
        onExerciseTapped: ((ExerciseStats) -> ())? = nil
    ) {
        self.loader = loader
        self.onExerciseTapped = onExerciseTapped
    }
    
    func loadExercises() async {
        do {
            exercises = try await loader.load()
        } catch {
            print(String(describing: error))
        }
    }
}
