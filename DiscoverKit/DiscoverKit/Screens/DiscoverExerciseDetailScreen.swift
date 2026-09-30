//
//  DiscoverExerciseDetailScreen.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 30/09/2026.
//

import SwiftUI

/// An exercise's DISCOVER page. For now its header and rating; tags, comments
/// and the exercise's clips join it in later steps of the plan.
struct DiscoverExerciseDetailScreen: View {

    let card: DiscoverExerciseCard
    @ObservedObject var ratingViewModel: DiscoverRatingViewModel

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
            }
            .padding()
        }
        .background {
            Color.darkColor.ignoresSafeArea()
        }
        .navigationTitle(card.name)
        .navigationBarTitleDisplayMode(.inline)
        .task { await ratingViewModel.load() }
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
            )
        )
    }
}
