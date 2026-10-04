//
//  ProfileKitComposition.swift
//  InTheGym
//
//  Created by Findlay Wood on 03/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//
import DiscoverKit
import UIKit
import ProfileKit


class ProfileKitComposition {

    /// The PROFILE tab. Player tab bar only; the coach tab bar keeps the legacy
    /// `MyProfileCoordinator` until the coach/player split is removed. See
    /// `PROFILE_PLAN.md`.
    @MainActor
    func composeCombination(_ navigationController: UINavigationController, purchaseManager: PurchaseManager) {

        let router = makeRouter(navigationController, purchaseManager: purchaseManager)

        // MARK: - App screens

        let appRoutes = ProfileAppRoutes(navigationController: navigationController, purchaseManager: purchaseManager)

        router.onShowPaywall = { appRoutes.showPaywall() }
        router.onManageSubscription = { appRoutes.showManageSubscription() }
        router.onOpenPerformanceCenter = { appRoutes.showPerformanceCenter() }
        router.onOpenAbout = { appRoutes.showAbout() }

        router.start()
    }

    /// A fully wired router on any navigation controller, **without** `start()`.
    /// The tab uses it above; DISCOVER (`ProfileKitUserProfileOpener`) and the
    /// legacy `UserProfileCoordinator` build one on their own stack and call
    /// `showUserProfile(_:)`. One graph for every entry point, so a profile
    /// opened from DISCOVER behaves exactly like one opened from a follow list
    /// (`PROFILE_PLAN.md` step 7).
    @MainActor
    func makeRouter(_ navigationController: UINavigationController, purchaseManager: PurchaseManager) -> ProfileKitRouter {

        // MARK: - Profile

        let profileLoader: MyProfileLoader = CurrentUserMyProfileLoader()

        let photoLoader: ProfilePhotoLoader = ImageCacheProfilePhotoLoader()

        // MARK: - Edit profile

        let userId = UserDefaults.currentUser.uid

        let remoteDetailsWriter: ProfileDetailsWriter = FirestoreProfileDetailsWriter(userId: userId)

        let detailsWriter: ProfileDetailsWriter = RemoteAndCurrentUserProfileDetailsWriter(
            remote: remoteDetailsWriter,
            currentUser: CurrentUserProfileDetailsWriter()
        )

        let storagePhotoUploader: ProfilePhotoUploader = StorageProfilePhotoUploader(userId: userId)

        let photoUploader: ProfilePhotoUploader = CachingProfilePhotoUploader(wrapping: storagePhotoUploader, userId: userId)

        // MARK: - Body measurements

        let bodyMeasurementsLoader: BodyMeasurementsLoader = FirestoreBodyMeasurementsLoader(userId: userId)

        let bodyMeasurementsWriter: BodyMeasurementsWriter = FirestoreBodyMeasurementsWriter(userId: userId)

        let weightLogLoader: WeightLogLoader = FirestoreWeightLogLoader(userId: userId)

        let weightEntryWriter: WeightEntryWriter = FirestoreWeightEntryWriter(userId: userId)

        let weightEntryRemover: WeightEntryRemover = FirestoreWeightEntryRemover(userId: userId)

        // MARK: - Follows

        let followListLoader: FollowListLoader = FirestoreFollowListLoader()

        let summaryLoader: ProfileSummaryLoader = FirestoreProfileSummaryLoader()

        let followStatusLoader: FollowStatusLoader = FirestoreFollowStatusLoader(currentUserId: userId)

        let followWriter: FollowWriter = FirestoreFollowWriter(currentUserId: userId)

        let unfollower: Unfollower = FirestoreUnfollower(currentUserId: userId)

        let followerRemover: FollowerRemover = FirestoreFollowerRemover(currentUserId: userId)

        // MARK: - Private account and requests

        let privateAccountLoader: PrivateAccountLoader = FirestorePrivateAccountLoader(userId: userId)

        let privateAccountWriter: PrivateAccountWriter = FirestorePrivateAccountWriter(userId: userId)

        let followRequestsLoader: FollowRequestsLoader = FirestoreFollowRequestsLoader(currentUserId: userId)

        let followRequestCountLoader: FollowRequestCountLoader = FirestoreFollowRequestCountLoader(currentUserId: userId)

        let followRequestApprover: FollowRequestApprover = FirestoreFollowRequestApprover(currentUserId: userId)

        // MARK: - Other people

        let publicProfileLoader: PublicProfileLoader = FirestorePublicProfileLoader()

        let userSearchLoader: UserSearchLoader = FirestoreUserSearchLoader()

        // MARK: - Highlights and clips

        let highlightsLoader: ProfileHighlightsLoader = FirestoreProfileHighlightsLoader()

        let clipsLoader: ProfileClipsLoader = FirestoreProfileClipsLoader()

        let highlightCandidatesLoader: HighlightCandidatesLoader = FirestoreHighlightCandidatesLoader(userId: userId)

        let pinnedHighlightsWriter: PinnedHighlightsWriter = FirestorePinnedHighlightsWriter(userId: userId)

        // MARK: - Report and block

        let reporter: ProfileReporter = FirestoreProfileReporter(userId: userId)

        let blockedUsersWriter: BlockedUsersWriter = FirestoreBlockedUsersWriter(userId: userId)

        let blocker: ProfileBlocker = BlockedUsersProfileBlocker(wrapping: blockedUsersWriter)

        let blockStatusLoader: ProfileBlockStatusLoader = FirestoreProfileBlockStatusLoader(userId: userId)

        // MARK: - Account deletion

        let accountDeleter: AccountDeleter = FirebaseAccountDeleter(userId: userId)

        // MARK: - Settings

        let subscription: ProfileSubscriptionService = PurchaseManagerSubscriptionService(purchaseManager: purchaseManager)

        let signOutService: ProfileSignOutService = AppSignOut()

        let passwordReset: PasswordResetService = FirebaseProfilePasswordReset(email: UserDefaults.currentUser.email)

        let links = ProfileSettingsLinks(
            instagram: URL(string: Constants.instagramLink)!,
            website: URL(string: Constants.websiteString)!,
            icons: URL(string: Constants.icons8Link)!,
            contactEmail: Constants.contactEmail
        )

        // MARK: - Router

        let router = ProfileKitRouter(
            navigationController: navigationController,
            profileLoader: profileLoader,
            photoLoader: photoLoader,
            subscription: subscription,
            signOutService: signOutService,
            passwordReset: passwordReset,
            detailsWriter: detailsWriter,
            photoUploader: photoUploader,
            bodyMeasurementsLoader: bodyMeasurementsLoader,
            bodyMeasurementsWriter: bodyMeasurementsWriter,
            weightLogLoader: weightLogLoader,
            weightEntryWriter: weightEntryWriter,
            weightEntryRemover: weightEntryRemover,
            followListLoader: followListLoader,
            summaryLoader: summaryLoader,
            followStatusLoader: followStatusLoader,
            followWriter: followWriter,
            unfollower: unfollower,
            followerRemover: followerRemover,
            privateAccountLoader: privateAccountLoader,
            privateAccountWriter: privateAccountWriter,
            followRequestsLoader: followRequestsLoader,
            followRequestCountLoader: followRequestCountLoader,
            followRequestApprover: followRequestApprover,
            publicProfileLoader: publicProfileLoader,
            userSearchLoader: userSearchLoader,
            highlightsLoader: highlightsLoader,
            clipsLoader: clipsLoader,
            highlightCandidatesLoader: highlightCandidatesLoader,
            pinnedHighlightsWriter: pinnedHighlightsWriter,
            reporter: reporter,
            blocker: blocker,
            blockStatusLoader: blockStatusLoader,
            accountDeleter: accountDeleter,
            links: links,
            accountEmail: UserDefaults.currentUser.email,
            currentUserId: userId
        )

        // Clips open in DISCOVER's player, through a DiscoverKit router built on
        // this same stack, lazily, on the first tap. Building it here eagerly
        // would recurse: DISCOVER's composition builds a ProfileKit router too.
        let clipOpener = DiscoverClipOpener(navigationController: navigationController, purchaseManager: purchaseManager)
        router.onOpenClip = { clipOpener.open($0) }

        return router
    }
}
