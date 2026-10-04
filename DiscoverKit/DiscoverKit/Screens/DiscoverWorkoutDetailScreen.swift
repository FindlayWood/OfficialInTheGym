//
//  DiscoverWorkoutDetailScreen.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 30/09/2026.
//

import SwiftUI

/// A workout's DISCOVER page: who made it, what is in it, saving a copy to the
/// user's library, then its rating, tags and the way into its comments.
///
/// The one action is **Save to Library**, never "Add to Today" — putting a
/// workout on a day is MyDay's job, from the library, where the date strip is.
struct DiscoverWorkoutDetailScreen: View {

    let card: DiscoverWorkoutCard
    @ObservedObject var detailViewModel: DiscoverWorkoutDetailViewModel
    @ObservedObject var ratingViewModel: DiscoverRatingViewModel
    @ObservedObject var taggingViewModel: DiscoverTaggingViewModel
    @ObservedObject var moderation: DiscoverModerationStore
    /// False on the user's own workout.
    var canReport = false
    /// Called once a report is filed and its sheet closed — the screen leaves,
    /// since what it shows is now hidden from this user.
    var onReported: () -> Void = {}

    @State private var reportRequest: DiscoverReportRequest?
    var onOpenComments: () -> Void = {}
    var onTagTapped: (String) -> Void = { _ in }
    /// Nil when profiles cannot be opened, or for your own workout.
    var onOpenAuthor: (() -> Void)?

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
                            if let author = detailViewModel.authorName {
                                if let onOpenAuthor {
                                    Button(action: onOpenAuthor) {
                                        HStack(spacing: 3) {
                                            Text("by \(author)")
                                            Image(systemName: "chevron.right")
                                                .font(.system(size: 10, weight: .bold))
                                        }
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundStyle(Color.darkColor)
                                    }
                                    .buttonStyle(.plain)
                                } else {
                                    Text("by \(author)")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundStyle(Color.darkColor)
                                }
                            }
                        }
                        Spacer(minLength: 0)
                    }
                    .padding(16)
                    if case .loaded(let detail) = detailViewModel.detail,
                       let description = detail.description,
                       !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        Divider()
                        Text(description)
                            .font(.system(size: 14))
                            .foregroundStyle(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(16)
                    }
                }

                if detailViewModel.saveState != .unavailable {
                    DiscoverSaveToLibraryButton(state: detailViewModel.saveState) {
                        Task { await detailViewModel.save() }
                    }
                }

                DiscoverWorkoutExercisesSection(state: detailViewModel.detail) {
                    Task { await detailViewModel.loadDetail() }
                }

                DiscoverRatingSection(viewModel: ratingViewModel)

                DiscoverTagsSection(viewModel: taggingViewModel, moderation: moderation, onTagTapped: onTagTapped)

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
            async let detail: Void = detailViewModel.load()
            async let rating: Void = ratingViewModel.load()
            async let tags: Void = taggingViewModel.load()
            async let moderationState: Void = moderation.loadIfNeeded()
            _ = await (detail, rating, tags, moderationState)
        }
        .toolbar {
            if canReport {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button("Report workout", systemImage: "flag") {
                            reportRequest = DiscoverReportRequest(target: .workout(id: card.templateId))
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
        .sheet(item: $reportRequest) { request in
            DiscoverReportSheet(target: request.target, moderation: moderation, onFinished: onReported)
                .presentationDetents([.medium])
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
            detailViewModel: DiscoverWorkoutDetailViewModel(
                templateId: card.templateId,
                createdBy: "u1",
                detailLoader: PreviewWorkoutLoaders(),
                profileLoader: PreviewUserProfileLoader(),
                copySaver: PreviewWorkoutLoaders(),
                copyChecker: PreviewWorkoutLoaders()
            ),
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
            ),
            moderation: PreviewModeration.store()
        )
    }
}
