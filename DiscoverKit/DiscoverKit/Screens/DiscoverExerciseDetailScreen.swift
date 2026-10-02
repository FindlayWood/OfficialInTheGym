//
//  DiscoverExerciseDetailScreen.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 30/09/2026.
//

import SwiftUI

/// An exercise's DISCOVER page: its header, rating, tags, the clips of people
/// doing it, and the way into its comments.
struct DiscoverExerciseDetailScreen: View {

    let card: DiscoverExerciseCard
    @ObservedObject var clipsViewModel: DiscoverExerciseClipsViewModel
    @ObservedObject var ratingViewModel: DiscoverRatingViewModel
    @ObservedObject var taggingViewModel: DiscoverTaggingViewModel
    @ObservedObject var moderation: DiscoverModerationStore
    var onOpenComments: () -> Void = {}
    var onTagTapped: (String) -> Void = { _ in }
    var onClipTapped: (DiscoverClipCard) -> Void = { _ in }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                SectionContainer {
                    HStack(spacing: 12) {
                        DiscoverIconTile(systemName: "figure.strengthtraining.traditional")
                        VStack(alignment: .leading, spacing: 3) {
                            Text(card.name)
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(.primary)
                            if let category = card.categoryDisplayName {
                                Text(category)
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundStyle(.secondary)
                            }
                        }
                        Spacer(minLength: 0)
                    }
                    .padding(16)
                }

                DiscoverRatingSection(viewModel: ratingViewModel)

                DiscoverTagsSection(viewModel: taggingViewModel, moderation: moderation, onTagTapped: onTagTapped)

                DiscoverExerciseClipsSection(viewModel: clipsViewModel, moderation: moderation, onClipTapped: onClipTapped)

                DiscoverCommentsEntrySection(count: card.commentCount ?? 0, onOpen: onOpenComments)
            }
            .padding()
        }
        .background {
            Color.darkColor.ignoresSafeArea()
        }
        .navigationTitle(card.name)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            async let clips: Void = clipsViewModel.load()
            async let rating: Void = ratingViewModel.load()
            async let tags: Void = taggingViewModel.load()
            async let moderationState: Void = moderation.loadIfNeeded()
            _ = await (clips, rating, tags, moderationState)
        }
    }
}

#Preview {
    let card = DiscoverExerciseCard(exerciseId: "squat", name: "Squat", category: "lower_body")
    NavigationStack {
        DiscoverExerciseDetailScreen(
            card: card,
            clipsViewModel: DiscoverExerciseClipsViewModel(exerciseId: card.exerciseId, loader: PreviewWorkoutLoaders()),
            ratingViewModel: DiscoverRatingViewModel(
                subject: .exercise(id: card.exerciseId),
                initialSummary: card.ratingSummary,
                canRate: true,
                summaryLoader: PreviewRatingSummaryLoader(),
                myRatingLoader: PreviewMyRatingLoader(rating: 8),
                writer: PreviewRatingWriter()
            ),
            taggingViewModel: DiscoverTaggingViewModel(
                subject: .exercise(id: "squat"),
                visibleTags: ["legs", "lowerbody", "squat"],
                counts: ["legs": 9, "lowerbody": 4, "squat": 3, "hotel": 1],
                canVote: true,
                normalizer: PreviewTagServices(),
                myTagsLoader: PreviewTagLoaders(),
                writer: PreviewTagServices(),
                suggestionLoader: PreviewTagLoaders()
            ),
            moderation: PreviewModeration.store()
        )
    }
}
