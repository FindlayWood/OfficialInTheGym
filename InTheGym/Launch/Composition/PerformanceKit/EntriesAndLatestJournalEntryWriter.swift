//
//  EntriesAndLatestJournalEntryWriter.swift
//  InTheGym
//
//  Created by Findlay Wood on 10/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//
import PerformanceKit

/// Writes a journal entry to the journal, then as the latest entry. It knows no
/// paths: each writer it wraps knows one.
///
/// The legacy view model wrote both documents in one `WriteBatch`. That is the
/// shape *Composition root mechanics* rules out, a writer that knows two
/// destinations. The order matters: the journal is the record, so it is
/// written first, and a failure there writes nothing else. A failure on the
/// second write leaves a saved entry with a stale latest-entry copy that
/// nothing in the app reads.
struct EntriesAndLatestJournalEntryWriter: JournalEntryWriter {

    let entries: JournalEntryWriter
    let latest: JournalEntryWriter

    func write(_ entry: JournalEntry) async throws {
        try await entries.write(entry)
        try await latest.write(entry)
    }
}
