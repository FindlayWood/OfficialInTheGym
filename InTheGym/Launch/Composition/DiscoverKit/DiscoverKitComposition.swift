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

    @MainActor
    func composeCombination(_ navigationController: UINavigationController) {

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
            currentUserId: userId
        )

        router.start()
    }
}
