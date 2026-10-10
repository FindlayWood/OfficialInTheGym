//
//  JournalServicesSpy.swift
//  PerformanceKitTests
//
//  Created by Findlay Wood on 10/10/2026.
//
import Foundation
@testable import PerformanceKit

/// Records every journal load and write. The results are settable so a test can
/// fail one and let the retry succeed. Never asserts — the test does.
final class JournalServicesSpy: JournalEntriesLoader, JournalEntryWriter, @unchecked Sendable {

    enum Message: Equatable {
        case loadEntries
        case write(JournalEntry)
    }

    private(set) var receivedMessages: [Message] = []
    var loadResult: Result<[JournalEntry], Error>
    var writeError: Error?

    init(loadResult: Result<[JournalEntry], Error> = .success([]), writeError: Error? = nil) {
        self.loadResult = loadResult
        self.writeError = writeError
    }

    func loadEntries() async throws -> [JournalEntry] {
        receivedMessages.append(.loadEntries)
        return try loadResult.get()
    }

    func write(_ entry: JournalEntry) async throws {
        receivedMessages.append(.write(entry))
        if let writeError { throw writeError }
    }
}
