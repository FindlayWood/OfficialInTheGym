//
//  DiscoverWorkoutDetailScreen.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 30/09/2026.
//

import SwiftUI

/// A workout's DISCOVER page: its header, rating, tags and the way into its
/// comments. The exercises and "Add to Today" join it in a later step.
struct DiscoverWorkoutDetailScreen: View {

    let card: DiscoverWorkoutCard
    @ObservedObject var ratingViewModel: DiscoverRatingViewModel
    @ObservedObject var taggingViewModel: DiscoverTaggingViewModel
    var onOpenComments: () -> Void = {}
    var onTagTapped: (String) -> Void = { _ in }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                SectionContainer {
                    HStack(spacing: 12) {
                        DiscoverIconTile(systemName: "dumbbell.fill")
                        VStack(alignment: .leading, spacing: 3) {
                            Text(card.title.isEmpty ? "Untitled workout" : card.title)
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(.primary)
                            Text(subtitle)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(.secondary)
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
        .navigationTitle(card.title)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            async let rating: Void = ratingViewModel.load()
            async let tags: Void = taggingViewModel.load()
            _ = await (rating, tags)
        }
    }

    private var subtitle: String {
        let count = card.exerciseCount == 1 ? "1 exercise" : "\(card.exerciseCount) exercises"
        guard let createdAt = card.createdAt else { return count }
        return count + " · " + createdAt.formatted(.dateTime.day().month(.abbreviated).year())
    }
}

#Preview {
    let card = DiscoverWorkoutCard(
        templateId: "t1", title: "Lower Body Strength", createdBy: "someone",
        exerciseCount: 5, createdAt: .now, isPublic: true, ratingCount: 3, ratingSum: 24
    )
    NavigationStack {
        DiscoverWorkoutDetailScreen(
            card: card,
            ratingViewModel: DiscoverRatingViewModel(
                subject: .workout(id: card.templateId),
                initialSummary: card.ratingSummary,
                canRate: true,
                summaryLoader: PreviewRatingSummaryLoader(),
                myRatingLoader: PreviewMyRatingLoader(),
                writer: PreviewRatingWriter()
            ),
            taggingViewModel: DiscoverTaggingViewModel(
                subject: .workout(id: card.templateId),
                visibleTags: ["legs", "strength"],
                counts: ["legs": 5, "strength": 3, "hotel": 2],
                canVote: true,
                normalizer: PreviewTagServices(),
                myTagsLoader: PreviewTagLoaders(),
                writer: PreviewTagServices(),
                suggestionLoader: PreviewTagLoaders()
            )
        )
    }
}
