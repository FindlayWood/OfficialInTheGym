//
//  ProPaywallViewModelTests.swift
//  InTheGymTests
//
//  Created by Findlay Wood on 12/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import XCTest
@testable import InTheGym

@MainActor
final class ProPaywallViewModelTests: XCTestCase {

    // Someone who already allowed notifications was promised a reminder on the paywall. Asking
    // them again would be a pointless screen between them and the app.
    func test_purchaseSelectedPlan_schedulesReminderWithoutAskingWhenAlreadyAllowed() async {
        let reminder = TrialReminderSchedulerSpy(permission: .allowed)
        let sut = await makeLoadedSUT(reminder: reminder)

        await sut.purchaseSelectedPlan()

        XCTAssertEqual(reminder.receivedMessages.count, 2)
        XCTAssertEqual(reminder.receivedMessages.first, .permission)
        assertSuccess(sut, trialStarted: true, isReminded: true)
    }

    func test_purchaseSelectedPlan_asksForReminderWhenNeverAsked() async {
        let reminder = TrialReminderSchedulerSpy(permission: .notAsked)
        let sut = await makeLoadedSUT(reminder: reminder)

        await sut.purchaseSelectedPlan()

        XCTAssertEqual(reminder.receivedMessages, [.permission])
        guard case .trialReminder(_, .notAsked) = sut.step else {
            return XCTFail("Expected the reminder step, got \(sut.step)")
        }
    }

    // A plan without a trial has nothing to remind about — the user goes straight to success.
    func test_purchaseSelectedPlan_skipsReminderForPlanWithoutTrial() async {
        let reminder = TrialReminderSchedulerSpy(permission: .notAsked)
        let sut = await makeLoadedSUT(reminder: reminder)
        sut.selectedPlanId = "sample_monthly"

        await sut.purchaseSelectedPlan()

        XCTAssertEqual(reminder.receivedMessages, [])
        assertSuccess(sut, trialStarted: false, isReminded: false)
    }

    func test_allowTrialReminder_schedulesWhenGranted() async {
        let reminder = TrialReminderSchedulerSpy(permission: .notAsked, requestResult: true)
        let sut = await makeLoadedSUT(reminder: reminder)
        await sut.purchaseSelectedPlan()

        await sut.allowTrialReminder()

        XCTAssertEqual(reminder.receivedMessages.count, 3)
        XCTAssertEqual(reminder.receivedMessages[1], .requestPermission)
        assertSuccess(sut, trialStarted: true, isReminded: true)
    }

    // Refusing the system prompt moves on rather than asking again; the success screen then says
    // when the trial ends instead of promising a reminder that will not come.
    func test_allowTrialReminder_continuesWithoutReminderWhenRefused() async {
        let reminder = TrialReminderSchedulerSpy(permission: .notAsked, requestResult: false)
        let sut = await makeLoadedSUT(reminder: reminder)
        await sut.purchaseSelectedPlan()

        await sut.allowTrialReminder()

        XCTAssertEqual(reminder.receivedMessages, [.permission, .requestPermission])
        assertSuccess(sut, trialStarted: true, isReminded: false)
    }

    func test_skipTrialReminder_deliversSuccessWithoutReminder() async {
        let reminder = TrialReminderSchedulerSpy(permission: .notAsked)
        let sut = await makeLoadedSUT(reminder: reminder)
        await sut.purchaseSelectedPlan()

        sut.skipTrialReminder()

        XCTAssertEqual(reminder.receivedMessages, [.permission])
        assertSuccess(sut, trialStarted: true, isReminded: false)
    }

    // Sent to Settings, the user turns notifications on and comes back: the reminder should be
    // scheduled then, without a second button to find.
    func test_recheckTrialReminderPermission_schedulesOnceAllowedInSettings() async {
        let reminder = TrialReminderSchedulerSpy(permission: .denied)
        let sut = await makeLoadedSUT(reminder: reminder)
        await sut.purchaseSelectedPlan()

        reminder.permissionResult = .allowed
        await sut.recheckTrialReminderPermission()

        assertSuccess(sut, trialStarted: true, isReminded: true)
    }

    // MARK: - Helpers

    private func makeLoadedSUT(reminder: TrialReminderSchedulerSpy, file: StaticString = #filePath, line: UInt = #line) async -> ProPaywallViewModel {
        let sut = ProPaywallViewModel(
            purchaseManager: PurchaseManagerStub(),
            backendService: PreviewFirestoreService(),
            trialReminder: reminder
        )
        await sut.loadPlans()
        XCTAssertEqual(sut.selectedPlan?.period, .year, "Expected yearly, the trial plan, preselected", file: file, line: line)
        return sut
    }

    private func assertSuccess(_ sut: ProPaywallViewModel, trialStarted: Bool, isReminded: Bool, file: StaticString = #filePath, line: UInt = #line) {
        guard case let .success(trial, reminded) = sut.step else {
            return XCTFail("Expected success, got \(sut.step)", file: file, line: line)
        }
        XCTAssertEqual(trial != nil, trialStarted, file: file, line: line)
        XCTAssertEqual(reminded, isReminded, file: file, line: line)
    }
}
