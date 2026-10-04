//
//  ProfileStampTests.swift
//  ProfileKitTests
//
//  Created by Findlay Wood on 03/10/2026.
//

import XCTest
@testable import ProfileKit

final class ProfileStampTests: XCTestCase {

    func test_stamps_deliversNoneForAPlainAccount() {
        let sut = ProfileStamp.stamps(for: .make(), hasUnlockedPro: false)

        XCTAssertEqual(sut, [])
    }

    // The legacy `UserStampsView` drew elite, verified, premium, in that order.
    // Reordering would move the badges people already recognise.
    func test_stamps_deliversAllThreeInTheLegacyOrder() {
        let sut = ProfileStamp.stamps(for: .make(isVerified: true, isElite: true), hasUnlockedPro: true)

        XCTAssertEqual(sut, [.elite, .verified, .premium])
    }

    // Premium comes only from the subscription, never from the profile. A crown
    // derived from anything else would show on other people's profiles that the
    // device cannot vouch for.
    func test_stamps_deliversPremiumOnlyWhenSubscribed() {
        let header = ProfileHeader.make(isVerified: true)

        XCTAssertEqual(ProfileStamp.stamps(for: header, hasUnlockedPro: false), [.verified])
        XCTAssertEqual(ProfileStamp.stamps(for: header, hasUnlockedPro: true), [.verified, .premium])
    }
}
