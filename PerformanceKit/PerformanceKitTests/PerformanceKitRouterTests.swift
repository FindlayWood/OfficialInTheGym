//
//  PerformanceKitRouterTests.swift
//  PerformanceKitTests
//
//  Created by Findlay Wood on 10/10/2026.
//

import UIKit
import XCTest
@testable import PerformanceKit

@MainActor
final class PerformanceKitRouterTests: XCTestCase {

    func test_open_showsThePaywallAndNoToolWithoutPro() {
        let (sut, events) = makeSUT(hasUnlockedPro: false)

        sut.open(.workload)

        XCTAssertEqual(events.messages, [.paywall])
    }

    func test_open_handsAToolStillInTheAppBackWithPro() {
        let (sut, events) = makeSUT(hasUnlockedPro: true)

        sut.open(.workload)

        XCTAssertEqual(events.messages, [.tool(.workload)])
    }

    // The journal has moved into PerformanceKit. Handing it to the app as well
    // would push the legacy journal on top of this one.
    func test_open_pushesTheJournalItselfWithPro() {
        let navigationController = UINavigationController()
        let (sut, events) = makeSUT(hasUnlockedPro: true, navigationController: navigationController)
        sut.start()

        sut.open(.journal)

        XCTAssertEqual(events.messages, [])
        XCTAssertEqual(navigationController.viewControllers.count, 2)
    }

    // Pro is read on every tap. A router that captured it when the tab was built
    // would keep showing the paywall to someone who has just subscribed.
    func test_open_readsProAgainOnEveryTap() {
        let access = PerformanceProAccessStub(hasUnlockedPro: false)
        let (sut, events) = makeSUT(access: access)

        sut.open(.workload)
        access.hasUnlockedPro = true
        sut.open(.workload)

        XCTAssertEqual(events.messages, [.paywall, .tool(.workload)])
    }

    func test_start_setsTheHomeScreenAsRoot() {
        let navigationController = UINavigationController()
        let (sut, _) = makeSUT(hasUnlockedPro: true, navigationController: navigationController)

        sut.start()

        XCTAssertEqual(navigationController.viewControllers.count, 1)
        XCTAssertIdentical(navigationController.viewControllers.first, sut.rootViewController)
    }

    func test_open_pushesVerticalJumpItselfWithPro() {
        let navigationController = UINavigationController()
        let (sut, events) = makeSUT(hasUnlockedPro: true, navigationController: navigationController)
        sut.start()

        sut.open(.verticalJump)

        XCTAssertEqual(events.messages, [])
        XCTAssertEqual(navigationController.viewControllers.count, 2)
    }

    func test_start_offersNoDismissOnTheTab() {
        let navigationController = UINavigationController()
        let (sut, _) = makeSUT(navigationController: navigationController)

        sut.start()

        XCTAssertNil(navigationController.viewControllers.first?.navigationItem.leftBarButtonItem)
    }

    // A presented Performance Center with no Dismiss button has no way out but
    // the swipe, which a full-screen presentation does not offer.
    func test_start_offersDismissWhenPresented() {
        let navigationController = UINavigationController()
        let (sut, _) = makeSUT(navigationController: navigationController)
        sut.onDismiss = {}

        sut.start()

        XCTAssertEqual(navigationController.viewControllers.first?.navigationItem.leftBarButtonItem?.title, "Dismiss")
    }

    // MARK: - Helpers

    private final class Events {
        enum Message: Equatable {
            case paywall
            case tool(PerformanceTool)
        }
        var messages: [Message] = []
    }

    private func makeSUT(
        hasUnlockedPro: Bool = false,
        access: PerformanceProAccessStub? = nil,
        navigationController: UINavigationController = UINavigationController(),
        athleteId: String = "me"
    ) -> (PerformanceKitRouter, Events) {
        let sut = PerformanceKitRouter(
            navigationController: navigationController,
            proAccess: access ?? PerformanceProAccessStub(hasUnlockedPro: hasUnlockedPro),
            journalLoader: JournalServicesSpy(),
            journalWriter: JournalServicesSpy(),
            maxJumpLoader: VerticalJumpServicesSpy(),
            jumpHistoryLoader: VerticalJumpServicesSpy(),
            jumpWriter: VerticalJumpServicesSpy(),
            currentUserId: "me",
            athleteId: athleteId
        )
        let events = Events()
        sut.onShowPaywall = { events.messages.append(.paywall) }
        sut.onOpenLegacyTool = { events.messages.append(.tool($0)) }
        return (sut, events)
    }
}
