//
//  JournalEntryViewModelTests.swift
//  PerformanceKitTests
//
//  Created by Findlay Wood on 10/10/2026.
//

import XCTest
@testable import PerformanceKit

@MainActor
final class JournalEntryViewModelTests: XCTestCase {

    func test_canUpload_deliversFalseForThreeCharactersOrFewer() {
        let sut = makeSUT()

        sut.entryText = "abc"

        XCTAssertFalse(sut.canUpload)
    }

    // Trailing whitespace is trimmed before the length is judged, so "abc   "
    // is still three characters. Counting it untrimmed would let a save through
    // that stores three characters.
    func test_canUpload_ignoresTrailingWhitespace() {
        let sut = makeSUT()

        sut.entryText = "abc   \n"

        XCTAssertFalse(sut.canUpload)
    }

    func test_canUpload_deliversTrueForMoreThanThreeCharacters() {
        let sut = makeSUT()

        sut.entryText = "abcd"

        XCTAssertTrue(sut.canUpload)
    }

    func test_upload_writesTheTrimmedEntryAndDeliversIt() async throws {
        let spy = JournalServicesSpy()
        let sut = makeSUT(spy: spy)
        sut.entryText = "  Good session  \n"

        let entry = try await sut.upload()

        let expected = JournalEntry(id: "new-id", date: .fixed, entry: "  Good session")
        XCTAssertEqual(entry, expected)
        XCTAssertEqual(spy.receivedMessages, [.write(expected)])
    }

    // The legacy view model left `isUploading` true after a failed write, so
    // the spinner replaced the button for good and the entry could not be
    // retried.
    func test_upload_stopsUploadingOnFailureSoItCanBeRetried() async {
        let sut = makeSUT(spy: JournalServicesSpy(writeError: NSError(domain: "test", code: 0)))
        sut.entryText = "Good session"

        _ = try? await sut.upload()

        XCTAssertFalse(sut.isUploading)
    }

    // MARK: - Helpers

    private func makeSUT(spy: JournalServicesSpy = JournalServicesSpy()) -> JournalEntryViewModel {
        JournalEntryViewModel(writer: spy, now: { .fixed }, makeId: { "new-id" })
    }
}
