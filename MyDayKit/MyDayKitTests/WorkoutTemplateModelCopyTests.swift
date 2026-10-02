//
//  WorkoutTemplateModelCopyTests.swift
//  MyDayKitTests
//
//  Created by Findlay Wood on 02/10/2026.
//

import XCTest
@testable import MyDayKit

final class WorkoutTemplateModelCopyTests: XCTestCase {

    // A copy is the saver's own — filed under them, not the author, or it
    // would sit in the saver's library as somebody else's workout.
    func test_copy_deliversTemplateOwnedBySaverWithNewId() {
        let sut = original().copy(savedBy: "saver", id: "copy-id", at: fixedDate)

        XCTAssertEqual(sut.id, "copy-id")
        XCTAssertEqual(sut.createdBy, "saver")
        XCTAssertEqual(sut.createdAt, fixedDate)
        XCTAssertEqual(sut.updatedAt, fixedDate)
    }

    // A public copy would list the author's workout in DISCOVER a second time
    // under the saver's name.
    func test_copy_deliversPrivateTemplateWhateverTheOriginal() {
        let sut = original().copy(savedBy: "saver")

        XCTAssertFalse(sut.isPublic)
    }

    func test_copy_recordsWhereItCameFrom() {
        let sut = original().copy(savedBy: "saver")

        XCTAssertEqual(sut.copiedFrom, "original-id")
    }

    func test_copy_keepsTheContentUnchanged() {
        let source = original()

        let sut = source.copy(savedBy: "saver")

        XCTAssertEqual(sut.title, source.title)
        XCTAssertEqual(sut.exercises.map(\.exerciseName), ["Squat"])
        XCTAssertEqual(sut.exercises.first?.sets.map(\.reps), [8, 8])
        XCTAssertEqual(sut.tags, ["legs"])
    }

    // `copiedFrom` is new and optional: every template written before it must
    // still decode, and one written without it must not gain the key.
    func test_decode_deliversNilCopiedFromForTemplatesWrittenBeforeIt() throws {
        let data = try JSONEncoder().encode(original())

        let sut = try JSONDecoder().decode(WorkoutTemplateModel.self, from: data)

        XCTAssertNil(sut.copiedFrom)
        XCTAssertFalse(String(decoding: data, as: UTF8.self).contains("copiedFrom"))
    }

    // MARK: - Helpers

    private let fixedDate = Date(timeIntervalSince1970: 1_790_000_000)

    private func original() -> WorkoutTemplateModel {
        WorkoutTemplateModel(
            id: "original-id",
            title: "Leg Day",
            description: nil,
            exercises: [
                WorkoutExerciseModel(
                    id: "e1",
                    exerciseId: "squat",
                    exerciseName: "Squat",
                    exerciseCategory: .lowerBody,
                    orderIndex: 0,
                    sets: [0, 1].map { WorkoutSetModel(id: "s\($0)", orderIndex: $0, reps: 8) }
                )
            ],
            createdBy: "author",
            isPublic: true,
            tags: ["legs"],
            estimatedDuration: nil,
            difficulty: nil,
            createdAt: Date(timeIntervalSince1970: 1_700_000_000),
            updatedAt: Date(timeIntervalSince1970: 1_700_000_000)
        )
    }
}
