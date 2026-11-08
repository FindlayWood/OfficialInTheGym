//
//  ScheduleStoreTests.swift
//  InTheGymTests
//
//  Created by Findlay Wood on 08/11/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//
import FirebaseFirestore
import MyDayKit
import XCTest
@testable import InTheGym

final class ScheduleStoreTests: XCTestCase {

    private let userId = "schedule-store-tests-\(UUID().uuidString)"

    override func tearDown() {
        LocalUserDataEraser(userId: userId).erase()
        super.tearDown()
    }

    // MARK: - Files

    // The writer and reader carry their own date strategies. If the two drift, every file stops
    // decoding and the user's cards vanish with nothing on screen to say why.
    func test_fileStore_deliversWhatWasWritten() async throws {
        let writer = FileManagerScheduleWriter(userId: userId)
        let sut = FileManagerScheduleFetcher(userId: userId)
        let schedules = [weeklySport(id: "sport"), oneOffWorkout(id: "workout")]

        for schedule in schedules {
            try await writer.upload(schedule)
        }

        let fetched = try await sut.fetchAll()
        XCTAssertEqual(fetched.sorted { $0.id < $1.id }, schedules)
    }

    func test_fileStore_deliversNothingBeforeTheFirstSave() async throws {
        let sut = FileManagerScheduleFetcher(userId: userId)

        let fetched = try await sut.fetchAll()

        XCTAssertEqual(fetched, [])
    }

    // A file this version cannot read, such as a frequency added later, must not take every other
    // schedule off MyDay.
    func test_fileStore_skipsAFileThatCannotDecode() async throws {
        let writer = FileManagerScheduleWriter(userId: userId)
        let sut = FileManagerScheduleFetcher(userId: userId)
        try await writer.upload(weeklySport(id: "good"))
        let damaged = ScheduleStoreLocation.directory(for: userId).appendingPathComponent("damaged.json")
        try Data(#"{"id":"damaged"}"#.utf8).write(to: damaged)

        let fetched = try await sut.fetchAll()

        XCTAssertEqual(fetched.map(\.id), ["good"])
    }

    // The device is shared. Without scoping, the next person to sign in would get these cards.
    func test_fileStore_doesNotDeliverAnotherUsersSchedules() async throws {
        let otherUser = "\(userId)-other"
        addTeardownBlock { LocalUserDataEraser(userId: otherUser).erase() }
        try await FileManagerScheduleWriter(userId: otherUser).upload(weeklySport(id: "theirs"))

        let fetched = try await FileManagerScheduleFetcher(userId: userId).fetchAll()

        XCTAssertEqual(fetched, [])
    }

    // MARK: - Queue

    func test_queue_holdsOnlyTheLatestWriteOfASchedule() async throws {
        let sut = SyncQueueScheduleUploader(userId: userId)
        let edited = weeklySport(id: "sport", updatedAt: fixedDate.addingTimeInterval(60))

        try await sut.upload(weeklySport(id: "sport"))
        try await sut.upload(edited)

        XCTAssertEqual(sut.loadPending(), [edited])
    }

    // An edit queued while the older write was uploading has not reached Firestore. Removing it by id
    // alone would lose it, and Firestore would keep the older version.
    func test_queue_keepsANewerEditWhenTheOlderVersionIsDequeued() async throws {
        let sut = SyncQueueScheduleUploader(userId: userId)
        let original = weeklySport(id: "sport")
        let edited = weeklySport(id: "sport", updatedAt: fixedDate.addingTimeInterval(60))
        try await sut.upload(edited)

        try sut.dequeue(original)

        XCTAssertEqual(sut.loadPending(), [edited])
    }

    // MARK: - Erasing

    func test_erase_removesSchedulesAndTheirQueue() async throws {
        let queue = SyncQueueScheduleUploader(userId: userId)
        try await FileManagerScheduleWriter(userId: userId).upload(weeklySport(id: "sport"))
        try await queue.upload(weeklySport(id: "sport"))

        LocalUserDataEraser(userId: userId).erase()

        let fetched = try await FileManagerScheduleFetcher(userId: userId).fetchAll()
        XCTAssertEqual(fetched, [])
        XCTAssertEqual(queue.loadPending(), [])
    }

    // MARK: - Firestore shape

    // These are what `firestore.rules` checks on `Users/{uid}/Schedules/{id}`: the id, and `item` and
    // `recurrence` as maps. If the encoder wrote anything else, the rule would refuse every upload,
    // and on a device that looks like a network error.
    func test_firestoreEncoder_writesTheShapeTheRulesExpect() throws {
        let sut = try Firestore.Encoder().encode(weeklySport(id: "sport"))

        XCTAssertEqual(sut["id"] as? String, "sport")
        XCTAssertNotNil(sut["item"] as? [String: Any])
        XCTAssertNotNil(sut["recurrence"] as? [String: Any])
        XCTAssertNotNil(sut["createdAt"] as? Timestamp)
        XCTAssertNotNil(sut["updatedAt"] as? Timestamp)
        XCTAssertNil(sut["stoppedAt"])
    }

    // Each is a map keyed by its case, which is why the uploader replaces rather than merges: a merge
    // would leave a document changed from weekly to every two weeks holding both keys.
    func test_firestoreEncoder_keysEachCaseSeparately() throws {
        let sut = try Firestore.Encoder().encode(weeklySport(id: "sport"))

        let recurrence = try XCTUnwrap(sut["recurrence"] as? [String: Any])
        let weekly = try XCTUnwrap(recurrence["weekly"] as? [String: Any])
        let item = try XCTUnwrap(sut["item"] as? [String: Any])
        XCTAssertEqual(Array(recurrence.keys), ["weekly"])
        XCTAssertEqual(weekly["start"] as? String, "2026-11-09")
        XCTAssertEqual(weekly["weekdays"] as? [Int], [ScheduleWeekday.tuesday.rawValue])
        XCTAssertEqual(Array(item.keys), ["sport"])
    }

    func test_firestoreCoding_deliversTheSameSchedule() throws {
        for schedule in [weeklySport(id: "sport"), oneOffWorkout(id: "workout")] {
            let encoded = try Firestore.Encoder().encode(schedule)

            XCTAssertEqual(try Firestore.Decoder().decode(Schedule.self, from: encoded), schedule)
        }
    }

    // MARK: - Helpers

    private let fixedDate = Date(timeIntervalSince1970: 1_800_000_000)

    private func weeklySport(id: String, updatedAt: Date? = nil) -> Schedule {
        Schedule(
            id: id,
            item: .sport(sport: .basketball, duration: 5_400),
            recurrence: .weekly(weekdays: [.tuesday], start: ScheduleDay(key: "2026-11-09")!),
            createdAt: fixedDate,
            updatedAt: updatedAt ?? fixedDate
        )
    }

    private func oneOffWorkout(id: String) -> Schedule {
        Schedule(
            id: id,
            item: .workout(templateId: "template"),
            recurrence: .once(day: ScheduleDay(key: "2026-11-10")!),
            createdAt: fixedDate,
            updatedAt: fixedDate
        )
    }
}
