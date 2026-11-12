//
//  ProfileWorkoutListScreen.swift
//  ProfileKit
//
//  Created by Findlay Wood on 12/11/2026.
//

import SwiftUI

/// A full list of workouts, pushed with the system bar: the section's See all, or All workouts.
/// See `ProfileWorkoutListViewModel`.
///
/// **View only.** There is no Create button: building starts only from MyDay, decided 2026-11-11.
/// A row opens through the opener, by the one destination rule.
struct ProfileWorkoutListScreen: View {

    @ObservedObject var viewModel: ProfileWorkoutListViewModel
    @ObservedObject var opener: ProfileWorkoutOpener

    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                switch viewModel.state {
                case .loading:
                    ForEach(0..<4, id: \.self) { _ in skeletonRow }
                case .failed:
                    ProfileLoadFailedCard { Task { await viewModel.load() } }
                case .loaded(let workouts) where workouts.isEmpty:
                    Text(viewModel.kind.emptyMessage)
                        .font(.system(size: 14))
                        .foregroundStyle(Color.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color(.secondarySystemBackground))
                        )
                case .loaded(let workouts):
                    ForEach(workouts) { workout in
                        Button {
                            opener.open(workout, from: viewModel.kind.source)
                        } label: {
                            ProfileWorkoutRow(workout: workout)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(16)
        }
        .refreshable { await viewModel.load() }
        .background(Color(.systemBackground).ignoresSafeArea())
        .navigationTitle(viewModel.kind.title)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { Task { await viewModel.load() } }
        .profileWorkoutChoice(opener)
    }

    /// The row's shape, so the list fills in rather than swapping layouts.
    private var skeletonRow: some View {
        VStack(alignment: .leading, spacing: 8) {
            RoundedRectangle(cornerRadius: 4).fill(Color(.tertiarySystemFill)).frame(width: 180, height: 16)
            RoundedRectangle(cornerRadius: 4).fill(Color(.tertiarySystemFill)).frame(width: 60, height: 12)
            RoundedRectangle(cornerRadius: 10).fill(Color(.tertiarySystemFill)).frame(width: 100, height: 22)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

#Preview {
    NavigationStack {
        ProfileWorkoutListScreen(
            viewModel: ProfileWorkoutListViewModel(
                kind: .library,
                workoutsLoader: PreviewWorkoutServices(),
                libraryLoader: PreviewWorkoutServices()
            ),
            opener: ProfileWorkoutOpener(currentUserId: "me", openWorkout: { _ in }, openDiscover: { _ in })
        )
    }
}
