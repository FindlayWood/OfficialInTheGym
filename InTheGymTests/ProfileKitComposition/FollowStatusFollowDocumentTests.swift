//
//  FollowStatusFollowDocumentTests.swift
//  InTheGymTests
//
//  Created by Findlay Wood on 04/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//
import ProfileKit
import XCTest
@testable import InTheGym

final class FollowStatusFollowDocumentTests: XCTestCase {

    func test_init_mapsTheStoredStatus() {
        XCTAssertEqual(FollowStatus(followDocumentStatus: "active"), .following)
        XCTAssertEqual(FollowStatus(followDocumentStatus: "pending"), .requested)
    }

    // No document is not following; so is a value from a future build this
    // one does not know. Guessing "following" would show content the rules
    // then deny.
    func test_init_treatsMissingOrUnknownAsNotFollowing() {
        XCTAssertEqual(FollowStatus(followDocumentStatus: nil), .notFollowing)
        XCTAssertEqual(FollowStatus(followDocumentStatus: "muted"), .notFollowing)
    }
}
