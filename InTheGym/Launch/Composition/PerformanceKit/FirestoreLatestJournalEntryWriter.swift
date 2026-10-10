//
//  FirestoreLatestJournalEntryWriter.swift
//  InTheGym
//
//  Created by Findlay Wood on 10/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//
import FirebaseFirestore
import PerformanceKit

/// Overwrites `Journal/{uid}` with the newest entry. See `JournalPath` for why
/// it is still written.
struct FirestoreLatestJournalEntryWriter: JournalEntryWriter {

    let userId: String

    func write(_ entry: JournalEntry) async throws {
        try await Firestore.firestore()
            .document(JournalPath.latest(of: userId))
            .setData(JournalEntryFields.fields(of: entry))
    }
}
