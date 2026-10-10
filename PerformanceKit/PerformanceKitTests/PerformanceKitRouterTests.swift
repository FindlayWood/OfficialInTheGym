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

    func test_start_setsTheRootScreen() {
        let navigationController = UINavigationController()
        let sut = makeSUT(navigationController: navigationController)

        sut.start()

        XCTAssertEqual(navigationController.viewControllers.count, 1)
        XCTAssertIdentical(navigationController.viewControllers.first, sut.rootViewController)
    }

    func test_open_pushesVerticalJump() {
        let navigationController = UINavigationController()
        let sut = makeSUT(navigationController: navigationController)
        sut.start()

        sut.open(.verticalJump)

        XCTAssertEqual(navigationController.viewControllers.count, 2)
    }

    func test_start_offersNoDismissOnTheTab() {
        let navigationController = UINavigationController()
        let sut = makeSUT(navigationController: navigationController)

        sut.start()

        XCTAssertNil(navigationController.viewControllers.first?.navigationItem.leftBarButtonItem)
    }

    // A presented Performance Center with no Dismiss button has no way out but
    // the swipe, which a full-screen presentation does not offer.
    func test_start_offersDismissWhenPresented() {
        let navigationController = UINavigationController()
        let sut = makeSUT(navigationController: navigationController)
        sut.onDismiss = {}

        sut.start()

        XCTAssertEqual(navigationController.viewControllers.first?.navigationItem.leftBarButtonItem?.title, "Dismiss")
    }

    // MARK: - Helpers

    private func makeSUT(navigationController: UINavigationController = UINavigationController()) -> PerformanceKitRouter {
        PerformanceKitRouter(
            navigationController: navigationController,
            proAccess: PerformanceProAccessStub(hasUnlockedPro: true),
            maxJumpLoader: VerticalJumpServicesSpy(),
            jumpHistoryLoader: VerticalJumpServicesSpy(),
            jumpWriter: VerticalJumpServicesSpy(),
            currentUserId: "me",
            athleteId: "me"
        )
    }
}
