//
//  FirestoreJournalEntriesLoader.swift
//  InTheGym
//
//  Created by Findlay Wood on 10/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//
import FirebaseFirestore
import PerformanceKit

/// Reads `Journal/{uid}/Entries`, newest first. Decoded per document, and an
/// entry that cannot be read is skipped rather than failing the whole journal,
/// the lesson of `FirestoreWorkoutTemplateFetcher`. The legacy view model
/// decoded them all in one `try`, so a single bad entry emptied the journal.
///
/// It no longer reads `Journal/{uid}`. The legacy view model did, threw the
/// result away, and when that document was missing the throw skipped working
/// out today's entries.
struct FirestoreJournalEntriesLoader: JournalEntriesLoader {

    let userId: String

    func loadEntries() async throws -> [JournalEntry] {
        let snapshot = try await Firestore.firestore()
            .collection(JournalPath.entries(of: userId))
            .order(by: "date", descending: true)
            .getDocuments()
        return snapshot.documents.compactMap { document in
            guard let date = (document.get("date") as? Timestamp)?.dateValue(),
                  let text = document.get("entry") as? String else {
                print("❌ Skipping journal entry \(document.documentID)")
                return nil
            }
            return JournalEntry(id: document.documentID, date: date, entry: text)
        }
    }
}
