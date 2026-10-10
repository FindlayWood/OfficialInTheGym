//
//  JournalEntryViewModel.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import Combine
import Foundation

/// Writing a new journal entry.
///
/// The rule for saving is the legacy one, unchanged: more than three
/// characters once trailing whitespace is trimmed, and it is the trimmed text
/// that is saved.
///
/// **A failed save puts the button back.** The legacy view model only cleared
/// `isUploading` on success, so one failed write left a spinner in place of the
/// button for good, with the text still in the editor and no way to try again.
@MainActor
final class JournalEntryViewModel: ObservableObject {

    @Published var entryText = ""
    @Published private(set) var isUploading = false

    private let writer: JournalEntryWriter
    private let now: () -> Date
    private let makeId: () -> String

    init(writer: JournalEntryWriter, now: @escaping () -> Date = Date.init, makeId: @escaping () -> String = { UUID().uuidString }) {
        self.writer = writer
        self.now = now
        self.makeId = makeId
    }

    var canUpload: Bool {
        entryText.trimmingTrailingWhitespace().count > 3
    }

    func upload() async throws -> JournalEntry {
        isUploading = true
        defer { isUploading = false }
        let entry = JournalEntry(id: makeId(), date: now(), entry: entryText.trimmingTrailingWhitespace())
        try await writer.write(entry)
        return entry
    }
}
