//
//  DiscoverKitRouter.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 28/09/2026.
//

import SwiftUI
import UIKit

/// The DISCOVER tab's router, in the shape `StatsKitRouter` set: every
/// dependency through `public init`, `start()` sets the root, and
/// `viewController(for:)` is the one place a view model meets its screen.
///
/// Exercises and workouts open their detail screens, clips open the player,
/// and all three lead to their comments.
///
/// `currentUserId` is the signed-in user, read once in the composition root.
/// The router needs it to decide what a user may do to their own content:
/// not rate or report their own workout, not report their own clip, delete
/// only their own comments.
///
/// `moderation` is the one `DiscoverModerationStore` for the flow — built here,
/// as a flow-scoped manager is, and handed to every screen that lists
/// something, so a block or report on one screen hides the thing on all of
/// them at once.
public final class DiscoverKitRouter {

    // MARK: - Navigation

    let navigationController: UINavigationController

    // MARK: - Dependencies

    let clipLoader: DiscoverClipCardLoader
    let workoutLoader: DiscoverWorkoutCardLoader
    let exerciseLoader: DiscoverExerciseCardLoader
    let ratingSummaryLoader: RatingSummaryLoader
    let myRatingLoader: MyRatingLoader
    let ratingWriter: RatingWriter
    let commentLoader: CommentLoader
    let replyLoader: ReplyLoader
    let commentWriter: CommentWriter
    let commentRemover: CommentRemover
    let likeLoader: LikeLoader
    let likeWriter: LikeWriter
    let profileLoader: UserProfileLoader
    let clipWatchRecorder: ClipWatchRecorder
    let popularTagsLoader: PopularTagsLoader
    let tagSuggestionLoader: TagSuggestionLoader
    let taggedExercisesLoader: TaggedExercisesLoader
    let taggedWorkoutsLoader: TaggedWorkoutsLoader
    let myTagVotesLoader: MyTagVotesLoader
    let tagVoteWriter: TagVoteWriter
    let tagNormalizer: TagNormalizer
    let blockedUsersLoader: BlockedUsersLoader
    let myReportsLoader: MyReportsLoader
    let reportWriter: ReportWriter
    let blockedUsersWriter: BlockedUsersWriter
    let currentUserId: String

    // MARK: - Properties

    private(set) var rootViewController: UIViewController?

    @MainActor
    private(set) lazy var moderation = DiscoverModerationStore(
        blockedLoader: blockedUsersLoader,
        reportsLoader: myReportsLoader,
        reportWriter: reportWriter,
        blockWriter: blockedUsersWriter
    )

    // MARK: - Init

    public init(
        navigationController: UINavigationController,
        clipLoader: DiscoverClipCardLoader,
        workoutLoader: DiscoverWorkoutCardLoader,
        exerciseLoader: DiscoverExerciseCardLoader,
        ratingSummaryLoader: RatingSummaryLoader,
        myRatingLoader: MyRatingLoader,
        ratingWriter: RatingWriter,
        commentLoader: CommentLoader,
        replyLoader: ReplyLoader,
        commentWriter: CommentWriter,
        commentRemover: CommentRemover,
        likeLoader: LikeLoader,
        likeWriter: LikeWriter,
        profileLoader: UserProfileLoader,
        clipWatchRecorder: ClipWatchRecorder,
        popularTagsLoader: PopularTagsLoader,
        tagSuggestionLoader: TagSuggestionLoader,
        taggedExercisesLoader: TaggedExercisesLoader,
        taggedWorkoutsLoader: TaggedWorkoutsLoader,
        myTagVotesLoader: MyTagVotesLoader,
        tagVoteWriter: TagVoteWriter,
        tagNormalizer: TagNormalizer,
        blockedUsersLoader: BlockedUsersLoader,
        myReportsLoader: MyReportsLoader,
        reportWriter: ReportWriter,
        blockedUsersWriter: BlockedUsersWriter,
        currentUserId: String
    ) {
        self.navigationController = navigationController
        self.clipLoader = clipLoader
        self.workoutLoader = workoutLoader
        self.exerciseLoader = exerciseLoader
        self.ratingSummaryLoader = ratingSummaryLoader
        self.myRatingLoader = myRatingLoader
        self.ratingWriter = ratingWriter
        self.commentLoader = commentLoader
        self.replyLoader = replyLoader
        self.commentWriter = commentWriter
        self.commentRemover = commentRemover
        self.likeLoader = likeLoader
        self.likeWriter = likeWriter
        self.profileLoader = profileLoader
        self.clipWatchRecorder = clipWatchRecorder
        self.popularTagsLoader = popularTagsLoader
        self.tagSuggestionLoader = tagSuggestionLoader
        self.taggedExercisesLoader = taggedExercisesLoader
        self.taggedWorkoutsLoader = taggedWorkoutsLoader
        self.myTagVotesLoader = myTagVotesLoader
        self.tagVoteWriter = tagVoteWriter
        self.tagNormalizer = tagNormalizer
        self.blockedUsersLoader = blockedUsersLoader
        self.myReportsLoader = myReportsLoader
        self.reportWriter = reportWriter
        self.blockedUsersWriter = blockedUsersWriter
        self.currentUserId = currentUserId
    }

    // MARK: - Root

    @MainActor
    public func start() {
        let rootVC = viewController(for: .home)
        rootViewController = rootVC
        navigationController.setViewControllers([rootVC], animated: false)
    }
}

extension DiscoverKitRouter {

    @MainActor
    func viewController(for route: DiscoverKitRoutes) -> UIViewController {
        switch route {
        case .home:
            let viewModel = DiscoverHomeViewModel(
                clipLoader: clipLoader,
                workoutLoader: workoutLoader,
                exerciseLoader: exerciseLoader,
                tagLoader: popularTagsLoader
            )
            viewModel.onTagTapped = { [weak self] in self?.navigate(to: .tag($0)) }
            viewModel.onSeeAllClips = { [weak self] in self?.navigate(to: .allClips) }
            viewModel.onSeeAllWorkouts = { [weak self] in self?.navigate(to: .allWorkouts) }
            viewModel.onSeeAllExercises = { [weak self] in self?.navigate(to: .allExercises) }
            viewModel.onWorkoutTapped = { [weak self] in self?.navigate(to: .workoutDetail($0)) }
            viewModel.onExerciseTapped = { [weak self] in self?.navigate(to: .exerciseDetail($0)) }
            viewModel.onClipTapped = { [weak self] in self?.navigate(to: .clipPlayer($0)) }
            let vc = DiscoverKitBoundaryViewController()
            vc.display = DiscoverHomeScreen(viewModel: viewModel, moderation: moderation)
            vc.router = self
            return vc

        case .allClips:
            let pager = DiscoverPager<DiscoverClipCard> { [clipLoader] limit, last in
                try await clipLoader.load(limit: limit, after: last)
            }
            let vc = UIHostingController(
                rootView: DiscoverClipGridScreen(
                    pager: pager,
                    moderation: moderation,
                    onTap: { [weak self] in self?.navigate(to: .clipPlayer($0)) }
                )
            )
            vc.hidesBottomBarWhenPushed = true
            return vc

        case .allWorkouts:
            let pager = DiscoverPager<DiscoverWorkoutCard> { [workoutLoader] limit, last in
                try await workoutLoader.load(limit: limit, after: last)
            }
            let vc = UIHostingController(
                rootView: DiscoverCardListScreen(
                    title: "Workouts",
                    emptyMessage: "No public workouts yet",
                    pager: pager,
                    moderation: moderation,
                    hides: { [moderation] in moderation.hides($0) },
                    onTap: { [weak self] in self?.navigate(to: .workoutDetail($0)) },
                    row: { DiscoverWorkoutRow(card: $0) }
                )
            )
            vc.hidesBottomBarWhenPushed = true
            return vc

        case .allExercises:
            let pager = DiscoverPager<DiscoverExerciseCard> { [exerciseLoader] limit, last in
                try await exerciseLoader.load(limit: limit, after: last)
            }
            let vc = UIHostingController(
                rootView: DiscoverCardListScreen(
                    title: "Exercises",
                    emptyMessage: "No exercises yet",
                    pager: pager,
                    moderation: moderation,
                    onTap: { [weak self] in self?.navigate(to: .exerciseDetail($0)) },
                    row: { DiscoverExerciseRow(card: $0) }
                )
            )
            vc.hidesBottomBarWhenPushed = true
            return vc

        case .exerciseDetail(let card):
            let ratingViewModel = makeRatingViewModel(
                subject: .exercise(id: card.exerciseId),
                summary: card.ratingSummary,
                canRate: true
            )
            let vc = UIHostingController(
                rootView: DiscoverExerciseDetailScreen(
                    card: card,
                    ratingViewModel: ratingViewModel,
                    taggingViewModel: makeTaggingViewModel(
                        subject: .exercise(id: card.exerciseId),
                        visibleTags: card.visibleTags,
                        counts: card.tagCounts,
                        canVote: true
                    ),
                    moderation: moderation,
                    onOpenComments: { [weak self] in self?.navigate(to: .comments(.exercise(id: card.exerciseId))) },
                    onTagTapped: { [weak self] in self?.navigate(to: .tag($0)) }
                )
            )
            vc.hidesBottomBarWhenPushed = true
            return vc

        case .workoutDetail(let card):
            let ratingViewModel = makeRatingViewModel(
                subject: .workout(id: card.templateId),
                summary: card.ratingSummary,
                canRate: card.createdBy != currentUserId
            )
            let vc = UIHostingController(
                rootView: DiscoverWorkoutDetailScreen(
                    card: card,
                    ratingViewModel: ratingViewModel,
                    taggingViewModel: makeTaggingViewModel(
                        subject: .workout(id: card.templateId),
                        visibleTags: card.visibleTags,
                        counts: card.tagCounts,
                        canVote: card.createdBy != currentUserId
                    ),
                    moderation: moderation,
                    canReport: card.createdBy != currentUserId,
                    onReported: { [weak self] in self?.navigationController.popViewController(animated: true) },
                    onOpenComments: { [weak self] in self?.navigate(to: .comments(.workout(id: card.templateId))) },
                    onTagTapped: { [weak self] in self?.navigate(to: .tag($0)) }
                )
            )
            vc.hidesBottomBarWhenPushed = true
            return vc

        case .comments(let subject):
            let viewModel = DiscoverCommentsViewModel(
                subject: subject,
                currentUserId: currentUserId,
                commentLoader: commentLoader,
                replyLoader: replyLoader,
                commentWriter: commentWriter,
                commentRemover: commentRemover,
                likeLoader: likeLoader,
                likeWriter: likeWriter,
                profileLoader: profileLoader
            )
            let vc = UIHostingController(
                rootView: DiscoverCommentsScreen(
                    viewModel: viewModel,
                    moderation: moderation,
                    onOpenBlockedUsers: { [weak self] in self?.navigate(to: .blockedUsers) }
                )
            )
            vc.hidesBottomBarWhenPushed = true
            return vc

        case .clipPlayer(let card):
            let viewModel = DiscoverClipPlayerViewModel(
                card: card,
                likeLoader: likeLoader,
                likeWriter: likeWriter,
                recorder: clipWatchRecorder
            )
            let vc = UIHostingController(
                rootView: DiscoverClipPlayerScreen(
                    viewModel: viewModel,
                    moderation: moderation,
                    canReport: card.createdBy != currentUserId,
                    onComments: { [weak self] in self?.navigate(to: .comments(.clip(id: card.clipId))) },
                    onClose: { [weak self] in self?.navigationController.popViewController(animated: true) }
                )
            )
            vc.hidesBottomBarWhenPushed = true
            return vc

        case .tag(let tag):
            let exercises = DiscoverPager<DiscoverTagged<DiscoverExerciseCard>> { [taggedExercisesLoader] limit, last in
                try await taggedExercisesLoader.exercises(taggedWith: tag, limit: limit, after: last)
            }
            let workouts = DiscoverPager<DiscoverTagged<DiscoverWorkoutCard>> { [taggedWorkoutsLoader] limit, last in
                try await taggedWorkoutsLoader.workouts(taggedWith: tag, limit: limit, after: last)
            }
            let vc = UIHostingController(
                rootView: DiscoverTagScreen(
                    tag: tag,
                    exercises: exercises,
                    workouts: workouts,
                    moderation: moderation,
                    onExerciseTapped: { [weak self] in self?.navigate(to: .exerciseDetail($0)) },
                    onWorkoutTapped: { [weak self] in self?.navigate(to: .workoutDetail($0)) }
                )
            )
            vc.hidesBottomBarWhenPushed = true
            return vc

        case .blockedUsers:
            let viewModel = DiscoverBlockedUsersViewModel(moderation: moderation, profileLoader: profileLoader)
            let vc = UIHostingController(
                rootView: DiscoverBlockedUsersScreen(viewModel: viewModel, moderation: moderation)
            )
            vc.hidesBottomBarWhenPushed = true
            return vc
        }
    }

    @MainActor
    private func makeTaggingViewModel(
        subject: DiscoverSubject,
        visibleTags: [String]?,
        counts: [String: Int]?,
        canVote: Bool
    ) -> DiscoverTaggingViewModel {
        DiscoverTaggingViewModel(
            subject: subject,
            visibleTags: visibleTags ?? [],
            counts: counts ?? [:],
            canVote: canVote,
            normalizer: tagNormalizer,
            myTagsLoader: myTagVotesLoader,
            writer: tagVoteWriter,
            suggestionLoader: tagSuggestionLoader
        )
    }

    @MainActor
    private func makeRatingViewModel(
        subject: DiscoverSubject,
        summary: RatingSummary,
        canRate: Bool
    ) -> DiscoverRatingViewModel {
        DiscoverRatingViewModel(
            subject: subject,
            initialSummary: summary,
            canRate: canRate,
            summaryLoader: ratingSummaryLoader,
            myRatingLoader: myRatingLoader,
            writer: ratingWriter
        )
    }

    @MainActor
    func navigate(to route: DiscoverKitRoutes) {
        navigationController.pushViewController(viewController(for: route), animated: true)
    }
}
