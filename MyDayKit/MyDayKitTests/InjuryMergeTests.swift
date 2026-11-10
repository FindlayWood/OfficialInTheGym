//
//  InjuryMergeTests.swift
//  MyDayKitTests
//
//  Created by Findlay Wood on 10/11/2026.
//

import XCTest
@testable import MyDayKit

final class InjuryMergeTests: XCTestCase {

    func test_merged_deliversInjuriesFromBothCopies() {
        let sut = Injury.merged(local: [.fixture(id: "phone")], remote: [.fixture(id: "tablet")])

        XCTAssertEqual(Set(sut.map(\.id)), ["phone", "tablet"])
    }

    func test_merged_takesTheInjurysFieldsFromTheLaterCopy() {
        let older = Injury.fixture(updatedAt: Date(timeIntervalSince1970: 100))
        let newer = Injury.fixture(resolvedOn: "2026-11-12", updatedAt: Date(timeIntervalSince1970: 200))

        XCTAssertEqual(Injury.merged(local: [older], remote: [newer]).first?.resolvedOn, .fixture("2026-11-12"))
        XCTAssertEqual(Injury.merged(local: [newer], remote: [older]).first?.resolvedOn, .fixture("2026-11-12"))
    }

    // Rated Tuesday on the phone and Wednesday on the iPad: each device uploads a copy missing
    // the other's day. Taking one copy whole would lose a day of history every time.
    func test_merged_keepsCheckInsFromBothCopiesWhicheverIsNewer() {
        let phone = Injury.fixture(checkIns: ["2026-11-10": .fixture(pain: 4)], updatedAt: Date(timeIntervalSince1970: 100))
        let tablet = Injury.fixture(checkIns: ["2026-11-11": .fixture(pain: 2)], updatedAt: Date(timeIntervalSince1970: 200))

        let sut = Injury.merged(local: [phone], remote: [tablet])

        XCTAssertEqual(sut.first?.checkIns.keys.sorted(), ["2026-11-10", "2026-11-11"])
    }

    func test_merged_takesTheLaterCheckInForTheSameDay() {
        let earlier = Injury.fixture(checkIns: ["2026-11-10": .fixture(pain: 6, at: 100)], updatedAt: Date(timeIntervalSince1970: 300))
        let later = Injury.fixture(checkIns: ["2026-11-10": .fixture(pain: 3, at: 200)], updatedAt: Date(timeIntervalSince1970: 100))

        XCTAssertEqual(Injury.merged(local: [earlier], remote: [later]).first?.checkIn(on: .fixture("2026-11-10"))?.pain, 3)
    }

    func test_merged_prefersLocalOnATie() {
        let local = Injury.fixture(checkIns: ["2026-11-10": .fixture(pain: 5)])
        let remote = Injury.fixture(checkIns: ["2026-11-10": .fixture(pain: 1)])

        XCTAssertEqual(Injury.merged(local: [local], remote: [remote]).first?.checkIn(on: .fixture("2026-11-10"))?.pain, 5)
    }

    // Removing marks rather than deletes, so the merge must carry the mark across.
    func test_merged_keepsARemovalFromTheLaterCopy() {
        let kept = Injury.fixture(updatedAt: Date(timeIntervalSince1970: 100))
        let removed = Injury.fixture(updatedAt: Date(timeIntervalSince1970: 200), removedAt: Date(timeIntervalSince1970: 200))

        XCTAssertNotNil(Injury.merged(local: [kept], remote: [removed]).first?.removedAt)
    }
}
