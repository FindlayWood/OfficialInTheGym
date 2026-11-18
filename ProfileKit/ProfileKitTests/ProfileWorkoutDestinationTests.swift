//
//  ProfileWorkoutDestinationTests.swift
//  ProfileKitTests
//
//  Created by Findlay Wood on 12/11/2026.
//

import XCTest
@testable import ProfileKit

final class ProfileWorkoutDestinationTests: XCTestCase {

    // MARK: - Public lists

    // Your own public workout has two pages, MyDay's and DISCOVER's, and the user picks.
    func test_init_deliversChoiceForYourOwnWorkoutInAPublicList() {
        let sut = destination(for: .make(createdBy: "me"), from: .publicCards)

        XCTAssertEqual(sut, .choice)
    }

    // You hold no copy of someone else's workout, so DISCOVER's page is the only one.
    func test_init_deliversDiscoverForSomeoneElsesWorkout() {
        let sut = destination(for: .make(createdBy: "alex"), from: .publicCards)

        XCTAssertEqual(sut, .discover)
    }

    // A router built for DISCOVER or a legacy screen has no MyDay. Offering a choice there would
    // put a button on screen that opens nothing.
    func test_init_deliversDiscoverForYourOwnWorkoutWhenMyDayCannotOpenIt() {
        let sut = destination(for: .make(createdBy: "me"), from: .publicCards, canOpenWorkout: false)

        XCTAssertEqual(sut, .discover)
    }

    func test_init_deliversWorkoutForYourOwnWorkoutWhenDiscoverCannotOpenIt() {
        let sut = destination(for: .make(createdBy: "me"), from: .publicCards, canOpenDiscover: false)

        XCTAssertEqual(sut, .workout)
    }

    func test_init_deliversNoneForSomeoneElsesWorkoutWhenDiscoverCannotOpenIt() {
        let sut = destination(for: .make(createdBy: "alex"), from: .publicCards, canOpenDiscover: false)

        XCTAssertEqual(sut, .none)
    }

    // MARK: - All workouts

    // All workouts reads the library, which still calls a workout public after moderation has hidden
    // its card. A choice there could offer a DISCOVER page that is gone.
    func test_init_deliversWorkoutForEveryLibraryRowPublicOrPrivate() {
        XCTAssertEqual(destination(for: .make(isPublic: true), from: .library), .workout)
        XCTAssertEqual(destination(for: .make(isPublic: false), from: .library), .workout)
    }

    func test_init_deliversNoneForALibraryRowWhenMyDayCannotOpenIt() {
        let sut = destination(for: .make(), from: .library, canOpenWorkout: false)

        XCTAssertEqual(sut, .none)
    }

    // MARK: - Lock

    func test_showsLock_isTrueOnlyForAPrivateWorkout() {
        XCTAssertTrue(ProfileWorkout.make(isPublic: false).showsLock)
        XCTAssertFalse(ProfileWorkout.make(isPublic: true).showsLock)
    }

    // MARK: - Helpers

    private func destination(
        for workout: ProfileWorkout,
        from source: ProfileWorkoutSource,
        canOpenWorkout: Bool = true,
        canOpenDiscover: Bool = true
    ) -> ProfileWorkoutDestination {
        ProfileWorkoutDestination(
            for: workout,
            from: source,
            currentUserId: "me",
            canOpenWorkout: canOpenWorkout,
            canOpenDiscover: canOpenDiscover
        )
    }
}
