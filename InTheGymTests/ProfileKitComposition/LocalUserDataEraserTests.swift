//
//  LocalUserDataEraserTests.swift
//  InTheGymTests
//
//  Created by Findlay Wood on 04/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//
import XCTest
@testable import InTheGym

final class LocalUserDataEraserTests: XCTestCase {

    private let userId = "testUser_eraser_\(UUID().uuidString)"
    private let otherId = "testUser_eraserOther_\(UUID().uuidString)"

    override func tearDown() {
        super.tearDown()
        for id in [userId, otherId] {
            try? FileManager.default.removeItem(at: MyDayStoreLocation.directory(for: id))
            try? FileManager.default.removeItem(at: WorkoutTemplateStoreLocation.directory(for: id))
            try? FileManager.default.removeItem(at: PendingSyncStoreLocation.workoutTemplatesFile(for: id))
        }
    }

    func test_erase_removesTheUsersDaysTemplatesAndSyncQueue() throws {
        try seed(userId)

        LocalUserDataEraser(userId: userId).erase()

        XCTAssertFalse(exists(MyDayStoreLocation.directory(for: userId)))
        XCTAssertFalse(exists(WorkoutTemplateStoreLocation.directory(for: userId)))
        XCTAssertFalse(exists(PendingSyncStoreLocation.workoutTemplatesFile(for: userId)))
    }

    // The phone is shared. Deleting one account must not touch another's data.
    func test_erase_leavesOtherUsersAlone() throws {
        try seed(userId)
        try seed(otherId)

        LocalUserDataEraser(userId: userId).erase()

        XCTAssertTrue(exists(MyDayStoreLocation.directory(for: otherId)))
        XCTAssertTrue(exists(WorkoutTemplateStoreLocation.directory(for: otherId)))
        XCTAssertTrue(exists(PendingSyncStoreLocation.workoutTemplatesFile(for: otherId)))
    }

    // Someone who never used MyDay on this phone has nothing to erase.
    func test_erase_succeedsWithNothingThere() {
        LocalUserDataEraser(userId: userId).erase()

        XCTAssertFalse(exists(MyDayStoreLocation.directory(for: userId)))
    }

    // MARK: - Helpers

    private func seed(_ id: String) throws {
        let fileManager = FileManager.default
        for directory in [MyDayStoreLocation.directory(for: id), WorkoutTemplateStoreLocation.directory(for: id)] {
            try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
            try Data("{}".utf8).write(to: directory.appendingPathComponent("file.json"))
        }
        try fileManager.createDirectory(at: PendingSyncStoreLocation.root, withIntermediateDirectories: true)
        try Data("[]".utf8).write(to: PendingSyncStoreLocation.workoutTemplatesFile(for: id))
    }

    private func exists(_ url: URL) -> Bool {
        FileManager.default.fileExists(atPath: url.path)
    }
}
