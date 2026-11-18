//
//  DiscoverWorkoutCommunityViewModel.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 18/11/2026.
//

import Combine
import Foundation

/// A workout page's community stats: the card's copy at once, then a fresh read.
///
/// **A failed read keeps what is shown.** The card's numbers are a little old, not wrong, and
/// blanking a visible section for a network blip says less than they do. A successful read that
/// finds none clears them: the workout has fallen below three people.
@MainActor
final class DiscoverWorkoutCommunityViewModel: ObservableObject {

    @Published private(set) var community: DiscoverWorkoutCommunity?

    private let templateId: String
    private let loader: WorkoutCommunityLoader

    init(templateId: String, initial: DiscoverWorkoutCommunity?, loader: WorkoutCommunityLoader) {
        self.templateId = templateId
        self.community = initial
        self.loader = loader
    }

    /// What the section draws, only from three people up.
    var shown: DiscoverWorkoutCommunity? {
        community.flatMap { $0.isShowable ? $0 : nil }
    }

    func load() async {
        do {
            community = try await loader.community(ofWorkout: templateId)
        } catch {
            print("❌ Workout community stats failed: \(error)")
        }
    }
}
