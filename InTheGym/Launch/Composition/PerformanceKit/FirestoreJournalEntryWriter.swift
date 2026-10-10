//
//  FirestoreJournalEntryWriter.swift
//  InTheGym
//
//  Created by Findlay Wood on 10/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//
import FirebaseFirestore
import PerformanceKit

/// Writes an entry to `Journal/{uid}/Entries/{entry.id}`, the journal itself.
/// The document holds `date` and `entry`, the same two fields the legacy
/// `JournalEntryModel` encoded, so old and new entries read alike.
struct FirestoreJournalEntryWriter: JournalEntryWriter {

    let userId: String

    func write(_ entry: JournalEntry) async throws {
        try await Firestore.firestore()
            .collection(JournalPath.entries(of: userId))
            .document(entry.id)
            .setData(JournalEntryFields.fields(of: entry))
    }
}
