//
//  ProfileSettingsViewModelTests.swift
//  ProfileKitTests
//
//  Created by Findlay Wood on 03/10/2026.
//

import XCTest
@testable import ProfileKit

@MainActor
final class ProfileSettingsViewModelTests: XCTestCase {

    // MARK: - Subscription

    func test_restorePurchases_deliversUnlockedWhenTheRestoreFindsAPurchase() async {
        let sut = makeSUT(subscription: ProfileSubscriptionServiceSpy(restoreFindsPurchase: true))

        await sut.viewModel.restorePurchases()

        XCTAssertEqual(sut.subscription.receivedMessages, [.restorePurchases])
        XCTAssertEqual(sut.viewModel.restoreState, .succeeded)
        XCTAssertTrue(sut.viewModel.hasUnlockedPro)
    }

    // A restore that finds nothing is still a success. The row reads "Nothing
    // to restore" rather than an error, so the user knows it ran.
    func test_restorePurchases_deliversSucceededButLockedWhenNothingIsFound() async {
        let sut = makeSUT()

        await sut.viewModel.restorePurchases()

        XCTAssertEqual(sut.viewModel.restoreState, .succeeded)
        XCTAssertFalse(sut.viewModel.hasUnlockedPro)
    }

    func test_restorePurchases_deliversFailedOnError() async {
        let sut = makeSUT(subscription: ProfileSubscriptionServiceSpy(error: anyError))

        await sut.viewModel.restorePurchases()

        XCTAssertEqual(sut.viewModel.restoreState, .failed)
    }

    // The paywall is presented over settings. Without a re-read on appear, a
    // purchase made there would still say "Not subscribed" when it is dismissed.
    func test_refreshSubscription_deliversAPurchaseMadeElsewhere() {
        let subscription = ProfileSubscriptionServiceSpy()
        let sut = makeSUT(subscription: subscription)
        subscription.hasUnlockedPro = true

        sut.viewModel.refreshSubscription()

        XCTAssertTrue(sut.viewModel.hasUnlockedPro)
    }

    // MARK: - Password reset

    func test_sendPasswordReset_deliversSucceeded() async {
        let sut = makeSUT()

        await sut.viewModel.sendPasswordReset()

        XCTAssertEqual(sut.passwordReset.receivedMessages, [.sendPasswordReset])
        XCTAssertEqual(sut.viewModel.passwordResetState, .succeeded)
    }

    // Repeated reset emails are what Firebase rate-limits. Once one has gone,
    // the row says so and a second tap sends nothing.
    func test_sendPasswordReset_doesNotSendAgainOnceSent() async {
        let sut = makeSUT()
        await sut.viewModel.sendPasswordReset()

        await sut.viewModel.sendPasswordReset()

        XCTAssertEqual(sut.passwordReset.receivedMessages, [.sendPasswordReset])
    }

    func test_sendPasswordReset_allowsARetryAfterAFailure() async {
        let passwordReset = PasswordResetServiceSpy(error: anyError)
        let sut = makeSUT(passwordReset: passwordReset)
        await sut.viewModel.sendPasswordReset()
        XCTAssertEqual(sut.viewModel.passwordResetState, .failed)
        passwordReset.error = nil

        await sut.viewModel.sendPasswordReset()

        XCTAssertEqual(passwordReset.receivedMessages, [.sendPasswordReset, .sendPasswordReset])
        XCTAssertEqual(sut.viewModel.passwordResetState, .succeeded)
    }

    // MARK: - Sign out

    func test_signOut_asksTheServiceToSignOut() async {
        let sut = makeSUT()

        await sut.viewModel.signOut()

        XCTAssertEqual(sut.signOut.receivedMessages, [.signOut])
        XCTAssertFalse(sut.viewModel.didFailToSignOut)
        XCTAssertFalse(sut.viewModel.isSigningOut)
    }

    // The legacy screen showed an error when sign-out failed. Silently staying
    // signed in would read as the button not working.
    func test_signOut_deliversFailureOnError() async {
        let sut = makeSUT(signOut: ProfileSignOutServiceSpy(error: anyError))

        await sut.viewModel.signOut()

        XCTAssertTrue(sut.viewModel.didFailToSignOut)
        XCTAssertFalse(sut.viewModel.isSigningOut)
    }

    // MARK: - Helpers

    private func makeSUT(
        subscription: ProfileSubscriptionServiceSpy = ProfileSubscriptionServiceSpy(),
        signOut: ProfileSignOutServiceSpy = ProfileSignOutServiceSpy(),
        passwordReset: PasswordResetServiceSpy = PasswordResetServiceSpy()
    ) -> (
        viewModel: ProfileSettingsViewModel,
        subscription: ProfileSubscriptionServiceSpy,
        signOut: ProfileSignOutServiceSpy,
        passwordReset: PasswordResetServiceSpy
    ) {
        let viewModel = ProfileSettingsViewModel(
            subscription: subscription,
            signOutService: signOut,
            passwordReset: passwordReset,
            links: anyLinks,
            appVersion: "1.0 (1)"
        )
        return (viewModel, subscription, signOut, passwordReset)
    }

    private var anyLinks: ProfileSettingsLinks {
        ProfileSettingsLinks(
            instagram: URL(string: "https://instagram.com")!,
            website: URL(string: "https://example.com")!,
            icons: URL(string: "https://icons8.com")!,
            contactEmail: "contact@example.com"
        )
    }
}

private let anyError = NSError(domain: "test", code: 0)
