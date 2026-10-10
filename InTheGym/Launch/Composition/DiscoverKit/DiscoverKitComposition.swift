//
//  DiscoverKitComposition.swift
//  InTheGym
//
//  Created by Findlay Wood on 28/09/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import UIKit
import DiscoverKit


class DiscoverKitComposition {

    /// `workoutLibrary` is MyDay's — see `MyDayWorkoutLibrary`. Nil on the coach
    /// tab bar, which has no MyDay, and then a workout page offers no Save.
    @MainActor
    func composeCombination(_ navigationController: UINavigationController, workoutLibrary: MyDayWorkoutLibrary?, purchaseManager: PurchaseManager) {
        makeRouter(navigationController, workoutLibrary: workoutLibrary, purchaseManager: purchaseManager).start()
    }

    /// A fully wired router on any navigation controller, **without** `start()`.
    /// The tab uses it above; ProfileKit's clips grid (`DiscoverClipOpener`)
    /// builds one on the profile's stack and calls `showClip(_:)`.
    @MainActor
    func makeRouter(_ navigationController: UINavigationController, workoutLibrary: MyDayWorkoutLibrary?, purchaseManager: PurchaseManager) -> DiscoverKitRouter {

        // MARK: - Card loaders

        let clipLoader: DiscoverClipCardLoader = FirestoreDiscoverClipCardLoader()

        let workoutLoader: DiscoverWorkoutCardLoader = FirestoreDiscoverWorkoutCardLoader()

        let exerciseLoader: DiscoverExerciseCardLoader = FirestoreDiscoverExerciseCardLoader()

        // MARK: - Ratings

        let userId = UserDefaults.currentUser.uid

        let ratingSummaryLoader: RatingSummaryLoader = FirestoreRatingSummaryLoader()

        let myRatingLoader: MyRatingLoader = FirestoreMyRatingLoader(userId: userId)

        let ratingWriter: RatingWriter = FirestoreRatingWriter(userId: userId)

        // MARK: - Comments and likes

        let commentLoader: CommentLoader = FirestoreCommentLoader()

        let replyLoader: ReplyLoader = FirestoreReplyLoader()

        let commentWriter: CommentWriter = FirestoreCommentWriter(userId: userId)

        let commentRemover: CommentRemover = FirestoreCommentRemover()

        let likeLoader: LikeLoader = FirestoreLikeLoader(userId: userId)

        let likeWriter: LikeWriter = FirestoreLikeWriter(userId: userId)

        // One cache for the session: comment threads are mostly the same few people.
        let profileLoader: UserProfileLoader = CachingUserProfileLoader(decoratee: FirestoreUserProfileLoader())

        let clipWatchRecorder: ClipWatchRecorder = FirebaseFunctionsViewClipRecorder()

        // MARK: - Tags

        let popularTagsLoader: PopularTagsLoader = FirestorePopularTagsLoader()

        let tagSuggestionLoader: TagSuggestionLoader = FirestoreTagSuggestionLoader()

        let taggedExercisesLoader: TaggedExercisesLoader = FirestoreTaggedExercisesLoader()

        let taggedWorkoutsLoader: TaggedWorkoutsLoader = FirestoreTaggedWorkoutsLoader()

        let myTagVotesLoader: MyTagVotesLoader = FirestoreMyTagVotesLoader(userId: userId)

        let tagVoteWriter: TagVoteWriter = FirestoreTagVoteWriter(userId: userId)

        let tagNormalizer: TagNormalizer = WorkoutTagNormalizer()

        // MARK: - Moderation

        let blockedUsersLoader: BlockedUsersLoader = FirestoreBlockedUsersLoader(userId: userId)

        let myReportsLoader: MyReportsLoader = FirestoreMyReportsLoader(userId: userId)

        let reportWriter: ReportWriter = FirestoreReportWriter(userId: userId)

        let blockedUsersWriter: BlockedUsersWriter = FirestoreBlockedUsersWriter(userId: userId)

        // MARK: - Workout and exercise pages

        let templateFetcher: WorkoutTemplateByIdFetching = FirestoreWorkoutTemplateByIdFetcher()

        let workoutDetailLoader: DiscoverWorkoutDetailLoader = TemplateDiscoverWorkoutDetailLoader(fetcher: templateFetcher)

        let exerciseClipsLoader: ExerciseClipsLoader = FirestoreExerciseClipsLoader()

        // MARK: - Search

        let peopleSearchLoader: PeopleSearchLoader = FirestorePeopleSearchLoader()

        let workoutSearchLoader: WorkoutSearchLoader = FirestoreWorkoutSearchLoader()

        // Exercises are searched on the device: the catalogue is read once per
        // router and matched locally, inside words and through typos.
        let exerciseCatalogueLoader: ExerciseCatalogueLoader = FirestoreExerciseCatalogueLoader()

        let exerciseSearchLoader: ExerciseSearchLoader = CatalogueExerciseSearchLoader(catalogue: exerciseCatalogueLoader)

        let workoutCopySaver: WorkoutCopySaver? = workoutLibrary.map {
            LibraryWorkoutCopySaver(fetcher: templateFetcher, library: $0, userId: userId)
        }

        let savedWorkoutCopyChecker: SavedWorkoutCopyChecker? = workoutLibrary.map {
            LibraryWorkoutCopyChecker(local: $0.local)
        }

        // MARK: - Profiles

        // A ProfileKit router on DISCOVER's own stack, so an author's profile
        // opens inside this tab. Built without start(); it only pushes.
        let profileOpener: UserProfileOpener = ProfileKitUserProfileOpener(
            router: ProfileKitComposition().makeRouter(navigationController, purchaseManager: purchaseManager)
        )

        // MARK: - Router

        let router = DiscoverKitRouter(
            navigationController: navigationController,
            clipLoader: clipLoader,
            workoutLoader: workoutLoader,
            exerciseLoader: exerciseLoader,
            ratingSummaryLoader: ratingSummaryLoader,
            myRatingLoader: myRatingLoader,
            ratingWriter: ratingWriter,
            commentLoader: commentLoader,
            replyLoader: replyLoader,
            commentWriter: commentWriter,
            commentRemover: commentRemover,
            likeLoader: likeLoader,
            likeWriter: likeWriter,
            profileLoader: profileLoader,
            clipWatchRecorder: clipWatchRecorder,
            popularTagsLoader: popularTagsLoader,
            tagSuggestionLoader: tagSuggestionLoader,
            taggedExercisesLoader: taggedExercisesLoader,
            taggedWorkoutsLoader: taggedWorkoutsLoader,
            myTagVotesLoader: myTagVotesLoader,
            tagVoteWriter: tagVoteWriter,
            tagNormalizer: tagNormalizer,
            blockedUsersLoader: blockedUsersLoader,
            myReportsLoader: myReportsLoader,
            reportWriter: reportWriter,
            blockedUsersWriter: blockedUsersWriter,
            workoutDetailLoader: workoutDetailLoader,
            exerciseClipsLoader: exerciseClipsLoader,
            peopleSearchLoader: peopleSearchLoader,
            workoutSearchLoader: workoutSearchLoader,
            exerciseSearchLoader: exerciseSearchLoader,
            workoutCopySaver: workoutCopySaver,
            savedWorkoutCopyChecker: savedWorkoutCopyChecker,
            profileOpener: profileOpener,
            currentUserId: userId
        )

        return router
    }
}
