//
//  ProfileKitComposition.swift
//  InTheGym
//
//  Created by Findlay Wood on 03/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//
import UIKit
import ProfileKit


class ProfileKitComposition {

    /// Player tab bar only. The coach tab bar keeps the legacy
    /// `MyProfileCoordinator` until the coach/player split is removed. See
    /// `PROFILE_PLAN.md`.
    @MainActor
    func composeCombination(_ navigationController: UINavigationController, purchaseManager: PurchaseManager) {

        // MARK: - Profile

        let profileLoader: MyProfileLoader = CurrentUserMyProfileLoader()

        let photoLoader: ProfilePhotoLoader = ImageCacheProfilePhotoLoader()

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
            links: links
        )

        // MARK: - App screens

        let appRoutes = ProfileAppRoutes(navigationController: navigationController, purchaseManager: purchaseManager)

        router.onShowPaywall = { appRoutes.showPaywall() }
        router.onManageSubscription = { appRoutes.showManageSubscription() }
        router.onOpenPerformanceCenter = { appRoutes.showPerformanceCenter() }
        router.onOpenAbout = { appRoutes.showAbout() }

        router.start()
    }
}
