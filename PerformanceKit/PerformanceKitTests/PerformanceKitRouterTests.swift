//
//  PerformanceKitRouterTests.swift
//  PerformanceKitTests
//
//  Created by Findlay Wood on 10/10/2026.
//

import UIKit
import SwiftUI
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

    func test_open_pushesEachTestsHome() {
        let navigationController = UINavigationController()
        let sut = makeSUT(navigationController: navigationController)
        sut.start()

        sut.open(.cmj)
        sut.open(.balance)

        XCTAssertEqual(navigationController.viewControllers.count, 3)
    }

    // The tab's root is the only screen that shows the tab bar. A pushed
    // screen pins its action to the bottom, which would sit over the tab bar.
    func test_navigate_hidesTheTabBarOnEveryPushedScreen() {
        let navigationController = UINavigationController()
        let sut = makeSUT(navigationController: navigationController)
        sut.start()

        sut.open(.cmj)

        XCTAssertFalse(navigationController.viewControllers[0].hidesBottomBarWhenPushed)
        XCTAssertTrue(navigationController.viewControllers[1].hidesBottomBarWhenPushed)
    }

    func test_start_offersNoDismissOnTheTab() {
        let navigationController = UINavigationController()
        let sut = makeSUT(navigationController: navigationController)

        sut.start()

        XCTAssertNil(rootScreen(of: navigationController)?.onDismiss)
    }

    // A presented Performance Center with no close button has no way out but
    // the swipe, which a full-screen presentation does not offer. The button
    // lives in the root's own header now that the system bar is hidden there.
    func test_start_offersDismissWhenPresented() {
        let navigationController = UINavigationController()
        let sut = makeSUT(navigationController: navigationController)
        var dismissed = 0
        sut.onDismiss = { dismissed += 1 }

        sut.start()
        rootScreen(of: navigationController)?.onDismiss?()

        XCTAssertEqual(dismissed, 1)
    }

    // MARK: - Helpers

    private func rootScreen(of navigationController: UINavigationController) -> PerformanceRootScreen? {
        (navigationController.viewControllers.first as? PerformanceKitHostingController<PerformanceRootScreen>)?.rootView
    }

    private func makeSUT(navigationController: UINavigationController = UINavigationController()) -> PerformanceKitRouter {
        PerformanceKitRouter(
            navigationController: navigationController,
            proAccess: PerformanceProAccessStub(hasUnlockedPro: true),
            jumpSessionsLoader: JumpTestServicesSpy(),
            jumpSessionWriter: JumpTestServicesSpy(),
            bodyMassLoader: BodyMassLoaderStub(),
            balanceSessionsLoader: BalanceServicesSpy(),
            balanceSessionWriter: BalanceServicesSpy(),
            currentUserId: "me",
            athleteId: "me"
        )
    }
}
