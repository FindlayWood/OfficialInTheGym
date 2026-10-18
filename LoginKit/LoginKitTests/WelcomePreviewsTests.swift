//
//  WelcomePreviewsTests.swift
//  LoginKitTests
//
//  Created by Findlay Wood on 18/10/2026.
//

import UIKit
import XCTest
@testable import LoginKit

final class WelcomePreviewsTests: XCTestCase {

    // A card with nothing behind it would be a claim with no proof — the
    // welcome screen must draw only what the app can actually open.
    func test_features_deliversNoCardsWithoutLaunchers() {
        let sut = WelcomePreviews()

        XCTAssertEqual(sut.features, [])
    }

    func test_features_deliversOnlySuppliedCardsInFixedOrder() {
        let sut = WelcomePreviews(workout: { _, _ in }, performance: { _ in })

        XCTAssertEqual(sut.features, [.training, .performance])
    }

    func test_features_deliversAllThreeWhenEverythingIsSupplied() {
        let sut = WelcomePreviews(workout: { _, _ in }, stats: { _ in }, performance: { _ in })

        XCTAssertEqual(sut.features, WelcomeFeature.allCases)
    }
}
