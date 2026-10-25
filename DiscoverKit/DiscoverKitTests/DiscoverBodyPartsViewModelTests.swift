//
//  DiscoverBodyPartsViewModelTests.swift
//  DiscoverKitTests
//
//  Created by Findlay Wood on 25/10/2026.
//

import XCTest
@testable import DiscoverKit

@MainActor
final class DiscoverBodyPartsViewModelTests: XCTestCase {

    // Names come from the lists, never from prettifying an id; an id the
    // lists do not hold is left out rather than shown raw.
    func test_worksNames_deliversMuscleGroupsThenPatternsByNameSkippingUnknownIds() async {
        let sut = makeSUT(groups: ["triceps", "madeup", "chest"], patterns: ["push_horizontal"])

        await sut.load()

        XCTAssertEqual(sut.worksNames, ["Triceps", "Chest", "Push Horizontal"])
    }

    func test_openSheet_startsFromTheCurrentValuesWhenTheUserHasNotSuggested() async {
        let sut = makeSUT(groups: ["chest"], patterns: ["push_horizontal"])
        await sut.load()

        sut.openSheet()

        XCTAssertEqual(sut.draftMuscleGroups, ["chest"])
        XCTAssertEqual(sut.draftMovementPatterns, ["push_horizontal"])
    }

    // Reopening on the current values would throw away what they sent.
    func test_openSheet_startsFromTheUsersOwnSuggestion() async {
        let mine = DiscoverBodyVote(muscleGroups: ["triceps"], movementPatterns: ["push_horizontal"])
        let sut = makeSUT(groups: ["chest"], patterns: ["push_horizontal"], myVote: mine)
        await sut.load()

        sut.openSheet()

        XCTAssertEqual(sut.draftMuscleGroups, ["triceps"])
    }

    // A suggestion is a whole set; one emptied of muscle groups must not be
    // sent, or a voter would count as saying the exercise works nothing.
    func test_toggle_savesOnlyACompleteSet() async {
        let writer = BodyVoteWriterSpy()
        let sut = makeSUT(groups: ["chest"], patterns: ["push_horizontal"], writer: writer)
        await sut.load()
        sut.openSheet()

        await sut.toggleMuscleGroup("chest")
        XCTAssertTrue(writer.receivedMessages.isEmpty)

        await sut.toggleMuscleGroup("triceps")

        XCTAssertEqual(writer.receivedMessages, [
            .setMyBodyVote(DiscoverBodyVote(muscleGroups: ["triceps"], movementPatterns: ["push_horizontal"]), exerciseId: "press")
        ])
        XCTAssertNotNil(sut.myVote)
    }

    // In the lists' order, so two people choosing the same set write the same
    // vote whatever order they tapped in.
    func test_toggle_writesIdsInTheListsOrder() async {
        let writer = BodyVoteWriterSpy()
        let sut = makeSUT(groups: ["triceps"], patterns: ["push_horizontal"], writer: writer)
        await sut.load()
        sut.openSheet()

        await sut.toggleMuscleGroup("chest")

        guard case let .setMyBodyVote(vote, _) = writer.receivedMessages.last else { return XCTFail("Nothing saved") }
        XCTAssertEqual(vote.muscleGroups, ["chest", "triceps"])
    }

    // MARK: - Helpers

    private func makeSUT(
        groups: [String],
        patterns: [String],
        myVote: DiscoverBodyVote? = nil,
        writer: BodyVoteWriter = BodyVoteWriterSpy()
    ) -> DiscoverBodyPartsViewModel {
        DiscoverBodyPartsViewModel(
            exerciseId: "press",
            muscleGroups: groups,
            movementPatterns: patterns,
            partsLoader: StubBodyParts(myVote: myVote),
            myVoteLoader: StubBodyParts(myVote: myVote),
            writer: writer
        )
    }

    private struct StubBodyParts: BodyPartsLoader, MyBodyVoteLoader {
        let myVote: DiscoverBodyVote?

        func loadBodyParts() async throws -> DiscoverBodyParts {
            DiscoverBodyParts(
                muscleGroups: [
                    DiscoverBodyPart(id: "chest", name: "Chest"),
                    DiscoverBodyPart(id: "triceps", name: "Triceps")
                ],
                movementPatterns: [DiscoverBodyPart(id: "push_horizontal", name: "Push Horizontal")]
            )
        }

        func myBodyVote(onExercise exerciseId: String) async throws -> DiscoverBodyVote? { myVote }
    }
}
