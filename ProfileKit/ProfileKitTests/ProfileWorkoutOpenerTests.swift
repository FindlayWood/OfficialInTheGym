//
//  ProfileWorkoutOpenerTests.swift
//  ProfileKitTests
//
//  Created by Findlay Wood on 12/11/2026.
//

import XCTest
@testable import ProfileKit

@MainActor
final class ProfileWorkoutOpenerTests: XCTestCase {

    func test_open_holdsYourOwnPublicWorkoutAsTheChoiceAndOpensNothing() {
        let (sut, opened) = makeSUT()

        sut.open(.make(createdBy: "me"), from: .publicCards)

        XCTAssertEqual(sut.choice?.workoutId, "w1")
        XCTAssertEqual(opened.messages, [])
    }

    func test_open_opensSomeoneElsesWorkoutOnDiscoverAtOnce() {
        let (sut, opened) = makeSUT()

        sut.open(.make(createdBy: "alex"), from: .publicCards)

        XCTAssertNil(sut.choice)
        XCTAssertEqual(opened.messages, [.discover("w1")])
    }

    func test_open_opensALibraryRowOnMyDayAtOnce() {
        let (sut, opened) = makeSUT()

        sut.open(.make(isPublic: false), from: .library)

        XCTAssertEqual(opened.messages, [.workout("w1")])
    }

    func test_chooseWorkout_opensTheChoiceOnMyDayAndClearsIt() {
        let (sut, opened) = makeSUT()
        sut.open(.make(createdBy: "me"), from: .publicCards)

        sut.chooseWorkout()

        XCTAssertNil(sut.choice)
        XCTAssertEqual(opened.messages, [.workout("w1")])
    }

    func test_chooseDiscover_opensTheChoiceOnDiscoverAndClearsIt() {
        let (sut, opened) = makeSUT()
        sut.open(.make(createdBy: "me"), from: .publicCards)

        sut.chooseDiscover()

        XCTAssertNil(sut.choice)
        XCTAssertEqual(opened.messages, [.discover("w1")])
    }

    func test_dismissChoice_clearsTheChoiceAndOpensNothing() {
        let (sut, opened) = makeSUT()
        sut.open(.make(createdBy: "me"), from: .publicCards)

        sut.dismissChoice()

        XCTAssertNil(sut.choice)
        XCTAssertEqual(opened.messages, [])
    }

    // A second tap on a choice button, while the card animates out, must not open a second page.
    func test_chooseWorkout_doesNothingWithoutAChoice() {
        let (sut, opened) = makeSUT()

        sut.chooseWorkout()

        XCTAssertEqual(opened.messages, [])
    }

    // MARK: - Helpers

    private final class Opened {
        enum Message: Equatable {
            case workout(String)
            case discover(String)
        }
        var messages: [Message] = []
    }

    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: ProfileWorkoutOpener, opened: Opened) {
        let opened = Opened()
        let sut = ProfileWorkoutOpener(
            currentUserId: "me",
            openWorkout: { [opened] in opened.messages.append(.workout($0)) },
            openDiscover: { [opened] in opened.messages.append(.discover($0.workoutId)) }
        )
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(opened, file: file, line: line)
        return (sut, opened)
    }
}
