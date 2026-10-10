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

    func test_open_opensTheToolWithPro() {
        let (sut, events) = makeSUT(hasUnlockedPro: true)

        sut.open(.journal)

        XCTAssertEqual(events.messages, [.tool(.journal)])
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
        navigationController: UINavigationController = UINavigationController()
    ) -> (PerformanceKitRouter, Events) {
        let sut = PerformanceKitRouter(
            navigationController: navigationController,
            proAccess: access ?? PerformanceProAccessStub(hasUnlockedPro: hasUnlockedPro),
            currentUserId: "me",
            athleteId: "me"
        )
        let events = Events()
        sut.onShowPaywall = { events.messages.append(.paywall) }
        sut.onOpenLegacyTool = { events.messages.append(.tool($0)) }
        return (sut, events)
    }
}
