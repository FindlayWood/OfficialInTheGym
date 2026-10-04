//
//  ProfileSettingsViewModel.swift
//  ProfileKit
//
//  Created by Findlay Wood on 03/10/2026.
//

import Combine
import Foundation

/// Settings, carried across from the legacy `SettingsViewController` and the
/// "More" menu: subscription, reset password, log out, and the about and
/// contact links.
///
/// What did not come across, and why:
/// - **Exercise Stats / Workout Stats.** The STATS tab replaces them.
/// - **Edit Profile.** Step 3 of `PROFILE_PLAN.md`, on the profile itself.
/// - **Measurements, My Coaches, Requests.** Already commented out of the old
///   menu, and the coach/player split is being removed.
///
/// **Performance Center keeps its entry point** under Tools, through
/// `onOpenPerformanceCenter`. It is a separate roadmap task and **none of its
/// code is to be deleted**. It was reachable from the old menu, so dropping the
/// row would quietly remove a feature (`PROFILE_PLAN.md`, open question 1).
///
/// Body Measurements (step 4) is a row under Account rather than part of Edit
/// Profile: it is private, and Edit Profile edits what other people see.
///
/// **Private Account** (step 6) is a switch under Account. It reads `nil` until
/// loaded, which disables the switch rather than showing a guess. Turning it
/// off asks first in the screen, because it approves every waiting request.
/// The change shows at once and is put back if the write fails.
///
/// **Delete Account** (step 10) sits at the very bottom, under Log Out, in red:
/// the last thing on the screen, never next to something routine.
@MainActor
final class ProfileSettingsViewModel: ObservableObject {

    @Published private(set) var hasUnlockedPro: Bool
    @Published private(set) var restoreState: ProfileActionState = .idle
    @Published private(set) var passwordResetState: ProfileActionState = .idle
    @Published private(set) var isSigningOut = false
    @Published var didFailToSignOut = false
    @Published private(set) var isPrivate: Bool?
    @Published private(set) var isSavingPrivacy = false
    @Published private(set) var privacyError: String?

    let links: ProfileSettingsLinks
    let appVersion: String
    /// The signed-in user's own sign-in address, shown under Account. It is the
    /// only place ProfileKit sees an email. Profiles never carry one
    /// (`ProfileHeader`), and this is never anyone else's.
    let accountEmail: String?

    private let subscription: ProfileSubscriptionService
    private let signOutService: ProfileSignOutService
    private let passwordReset: PasswordResetService
    private let privateAccountLoader: PrivateAccountLoader
    private let privateAccountWriter: PrivateAccountWriter

    var onShowPaywall: (() -> Void)?
    var onManageSubscription: (() -> Void)?
    var onOpenPerformanceCenter: (() -> Void)?
    var onOpenAbout: (() -> Void)?
    var onOpenBodyMeasurements: (() -> Void)?
    var onOpenDeleteAccount: (() -> Void)?

    init(
        subscription: ProfileSubscriptionService,
        signOutService: ProfileSignOutService,
        passwordReset: PasswordResetService,
        privateAccountLoader: PrivateAccountLoader,
        privateAccountWriter: PrivateAccountWriter,
        links: ProfileSettingsLinks,
        accountEmail: String? = nil,
        appVersion: String = Bundle.main.profileAppVersion
    ) {
        self.subscription = subscription
        self.signOutService = signOutService
        self.passwordReset = passwordReset
        self.privateAccountLoader = privateAccountLoader
        self.privateAccountWriter = privateAccountWriter
        self.links = links
        self.accountEmail = accountEmail
        self.appVersion = appVersion
        self.hasUnlockedPro = subscription.hasUnlockedPro
    }

    /// Re-read on appear: the paywall is presented over this screen, and a
    /// purchase made there has to show here when it is dismissed.
    func refreshSubscription() {
        hasUnlockedPro = subscription.hasUnlockedPro
    }

    func loadPrivacy() async {
        do {
            isPrivate = try await privateAccountLoader.isPrivate()
        } catch {
            print("❌ Private account setting failed: \(error)")
            privacyError = "Couldn't load your privacy setting."
        }
    }

    func setPrivate(_ value: Bool) async {
        guard let current = isPrivate, current != value, !isSavingPrivacy else { return }
        isSavingPrivacy = true
        privacyError = nil
        isPrivate = value
        defer { isSavingPrivacy = false }
        do {
            try await privateAccountWriter.setPrivate(value)
        } catch {
            print("❌ Private account save failed: \(error)")
            isPrivate = current
            privacyError = "Couldn't change your privacy setting. Check your connection and try again."
        }
    }

    func restorePurchases() async {
        guard !restoreState.isWorking else { return }
        restoreState = .working
        do {
            try await subscription.restorePurchases()
            hasUnlockedPro = subscription.hasUnlockedPro
            restoreState = .succeeded
        } catch {
            print("❌ Restore purchases failed: \(error)")
            restoreState = .failed
        }
    }

    /// Sends once per visit to the screen. A second send is the rate-limited
    /// repeat the state exists to prevent, and the row says the first one went.
    func sendPasswordReset() async {
        guard passwordResetState == .idle || passwordResetState == .failed else { return }
        passwordResetState = .working
        do {
            try await passwordReset.sendPasswordReset()
            passwordResetState = .succeeded
        } catch {
            print("❌ Password reset failed: \(error)")
            passwordResetState = .failed
        }
    }

    /// On success the app's `signOut` notification takes the user back to the
    /// welcome screen, so there is nothing to do here but stop on failure.
    func signOut() async {
        guard !isSigningOut else { return }
        isSigningOut = true
        do {
            try await signOutService.signOut()
        } catch {
            print("❌ Sign out failed: \(error)")
            didFailToSignOut = true
        }
        isSigningOut = false
    }
}
