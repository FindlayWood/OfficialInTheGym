//
//  DiscoverExerciseDetailScreen.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 30/09/2026.
//

import SwiftUI

/// An exercise's DISCOVER page: its header, rating, tags and the way into
/// its comments. The exercise's clips join it in a later step of the plan.
struct DiscoverExerciseDetailScreen: View {

    let card: DiscoverExerciseCard
    @ObservedObject var ratingViewModel: DiscoverRatingViewModel
    @ObservedObject var taggingViewModel: DiscoverTaggingViewModel
    var onOpenComments: () -> Void = {}
    var onTagTapped: (String) -> Void = { _ in }

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

                DiscoverTagsSection(viewModel: taggingViewModel, onTagTapped: onTagTapped)

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
            async let rating: Void = ratingViewModel.load()
            async let tags: Void = taggingViewModel.load()
            _ = await (rating, tags)
        }
    }
}

#Preview {
    let card = DiscoverExerciseCard(exerciseId: "squat", name: "Squat", category: "lower_body")
    NavigationStack {
        DiscoverExerciseDetailScreen(
            card: card,
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
            )
        )
    }
}
