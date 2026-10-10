//
//  JournalEntry.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import Foundation

/// One journal entry: when it was written, and what was written.
///
/// **`id` is stored.** The legacy `JournalEntryModel` worked out a fresh
/// `UUID()` on every read of `id`, so the same entry had a different identity
/// each time SwiftUI asked. The list could not tell a row it had already drawn
/// from a new one. The id is now the Firestore document id, set by the loader,
/// or minted once by the view model for an entry it is about to write.
public struct JournalEntry: Identifiable, Equatable, Sendable {
    public let id: String
    public let date: Date
    public let entry: String

    public init(id: String, date: Date, entry: String) {
        self.id = id
        self.date = date
        self.entry = entry
    }
}
