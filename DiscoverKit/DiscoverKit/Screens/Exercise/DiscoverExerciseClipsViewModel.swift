//
//  DiscoverExerciseClipsViewModel.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 02/10/2026.
//

import Combine
import Foundation

/// The clips on an exercise's page — the newest public ones, as a strip.
@MainActor
final class DiscoverExerciseClipsViewModel: ObservableObject {

    @Published private(set) var clips: DiscoverSectionState<[DiscoverClipCard]> = .loading

    static let limit = 12

    let exerciseId: String
    private let loader: ExerciseClipsLoader

    init(exerciseId: String, loader: ExerciseClipsLoader) {
        self.exerciseId = exerciseId
        self.loader = loader
    }

    func load() async {
        clips = .loading
        do {
            clips = .loaded(try await loader.clips(ofExercise: exerciseId, limit: Self.limit))
        } catch {
            print("❌ Exercise clips failed: \(error)")
            clips = .failed
        }
    }
}
