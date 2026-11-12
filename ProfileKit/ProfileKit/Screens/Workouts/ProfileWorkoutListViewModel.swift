//
//  ProfileWorkoutListViewModel.swift
//  ProfileKit
//
//  Created by Findlay Wood on 12/11/2026.
//

import Combine
import Foundation

/// A full list of workouts: someone's public ones, or your whole library.
///
/// **Re-read every time the screen appears.** The library is MyDay's, and a workout built there
/// since the last visit has to be listed on the way back. A refresh that fails keeps what is
/// already showing (offline means stale, not broken); only a first load that fails shows the retry.
@MainActor
final class ProfileWorkoutListViewModel: ObservableObject {

    /// More than a profile is likely to hold. The public list is one page, not paginated.
    static let publicLimit = 50

    @Published private(set) var state: ProfileLoadState<[ProfileWorkout]> = .loading

    let kind: ProfileWorkoutListKind
    private let workoutsLoader: ProfileWorkoutsLoader
    private let libraryLoader: ProfileLibraryLoader?

    init(kind: ProfileWorkoutListKind, workoutsLoader: ProfileWorkoutsLoader, libraryLoader: ProfileLibraryLoader?) {
        self.kind = kind
        self.workoutsLoader = workoutsLoader
        self.libraryLoader = libraryLoader
    }

    func load() async {
        if case .failed = state { state = .loading }
        do {
            state = .loaded(try await fetch())
        } catch {
            print("❌ Profile workouts failed: \(error)")
            if case .loaded = state { return }
            state = .failed
        }
    }

    private func fetch() async throws -> [ProfileWorkout] {
        switch kind {
        case .publicWorkouts(let userId):
            try await workoutsLoader.publicWorkouts(of: userId, limit: Self.publicLimit)
        case .library:
            try await libraryLoader?.allWorkouts() ?? []
        }
    }
}
