//
//  NewTrackedSessionViewModelTests.swift
//  PerformanceKitTests
//
//  Created by Findlay Wood on 10/10/2026.
//

import XCTest
@testable import PerformanceKit

@MainActor
final class NewTrackedSessionViewModelTests: XCTestCase {

    // The snapshot is taken before the session's own load is logged, so it
    // describes the athlete coming into the session. Logging first would count
    // the session in its own snapshot.
    func test_save_snapshotsThenStoresTheSessionThenLogsItsLoad() async throws {
        let spy = TrackerServicesSpy()
        let sut = makeSUT(kind: .match, spy: spy)

        _ = try await sut.save()

        XCTAssertEqual(spy.receivedMessages.map(\.name), ["loadWorkloads", "loadCMJ", "loadWellness", "writeSession", "writeWorkload"])
    }

    // The workload entry links back to the session by the id the session was
    // stored under. The id a session is built with is a placeholder.
    func test_save_linksTheLoggedLoadToTheStoredSession() async throws {
        let spy = TrackerServicesSpy()
        spy.storedSessionId = "abc"
        let sut = makeSUT(kind: .practice, spy: spy)
        sut.rpe = 6
        sut.duration = 50

        let session = try await sut.save()

        XCTAssertEqual(session.id, "abc")
        XCTAssertEqual(spy.receivedMessages.last, .writeWorkload(TrackedSessionKind.practice.workload(sessionId: "abc", endTime: .fixed, rpe: 6, durationMinutes: 50)))
    }

    func test_save_storesTheRatingsNotesAndSnapshot() async throws {
        let spy = TrackerServicesSpy()
        let older = Workload.make(total: 300, daysAgo: 3, id: "older")
        let newest = Workload.make(total: 700, daysAgo: 0, id: "newest")
        spy.workloadsResult = .success([older, newest])
        let sut = makeSUT(kind: .match, spy: spy)
        sut.ratings = TrackedSessionRatings(overall: 8, technical: 7, tactical: 6, physical: 9, mental: 4)
        sut.note = "Won 2-1"

        _ = try await sut.save()

        guard case .writeSession(let session, .match) = spy.receivedMessages.first(where: { $0.name == "writeSession" }) else {
            return XCTFail("Expected a match to be written")
        }
        XCTAssertEqual(session.ratings, TrackedSessionRatings(overall: 8, technical: 7, tactical: 6, physical: 9, mental: 4))
        XCTAssertEqual(session.notes, "Won 2-1")
        XCTAssertEqual(session.date, .fixed)
        XCTAssertEqual(session.mostRecentWorkload, newest)
        XCTAssertEqual(session.workloadRatio?.acuteLoad ?? 0, 1000, accuracy: 0.0001)
    }

    func test_save_writesNothingWhenTheWorkloadLogCannotBeRead() async {
        let spy = TrackerServicesSpy()
        spy.workloadsResult = .failure(anyError)
        let sut = makeSUT(kind: .match, spy: spy)

        _ = try? await sut.save()

        XCTAssertEqual(spy.receivedMessages.map(\.name), ["loadWorkloads"])
    }

    // The legacy trackers left the spinner up after a failure, so the entry
    // could never be retried. Both failure points must put the button back.
    func test_save_stopsUploadingOnFailureSoItCanBeRetried() async {
        let spy = TrackerServicesSpy()
        spy.workloadsResult = .failure(anyError)
        let sut = makeSUT(kind: .match, spy: spy)

        _ = try? await sut.save()
        XCTAssertFalse(sut.isUploading)

        spy.workloadsResult = .success([])
        spy.writeSessionError = anyError
        _ = try? await sut.save()
        XCTAssertFalse(sut.isUploading)
    }

    func test_save_doesNotLogLoadForASessionThatFailedToStore() async {
        let spy = TrackerServicesSpy()
        spy.writeSessionError = anyError
        let sut = makeSUT(kind: .match, spy: spy)

        _ = try? await sut.save()

        XCTAssertFalse(spy.receivedMessages.contains { $0.name == "writeWorkload" })
    }

    // MARK: - Helpers

    private func makeSUT(kind: TrackedSessionKind, spy: TrackerServicesSpy) -> NewTrackedSessionViewModel {
        NewTrackedSessionViewModel(
            kind: kind,
            workloadsLoader: spy,
            wellnessLoader: spy,
            cmjLoader: spy,
            sessionWriter: spy,
            workloadWriter: spy,
            now: { .fixed },
            calendar: .utc
        )
    }

    private var anyError: NSError { NSError(domain: "test", code: 0) }
}

private extension TrackerServicesSpy.Message {
    var name: String {
        switch self {
        case .loadSessions: "loadSessions"
        case .writeSession: "writeSession"
        case .loadWorkloads: "loadWorkloads"
        case .writeWorkload: "writeWorkload"
        case .loadWellness: "loadWellness"
        case .loadCMJ: "loadCMJ"
        }
    }
}
