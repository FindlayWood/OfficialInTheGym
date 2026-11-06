//
//  FirestoreSportSessionSaver.swift
//  InTheGym
//
//  Created by Findlay Wood on 05/11/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import FirebaseFirestore
import Foundation
import MyDayKit

/// Writes `Users/{userId}/SportSessions/{id}` — a sport session as a document of its own, which
/// the DailyTotals function counts toward session load. **This path only**; the day the session
/// is embedded in is the day saver's, and `MyDayThenSportSessionSaver` composes the two.
///
/// A replace, not a merge: nothing but the app writes this document, and an edit must not leave
/// a field the form has since cleared (a score on a game switched back to training).
final class FirestoreSportSessionSaver: SportSessionSaver {

    private let userId: String

    init(userId: String) {
        self.userId = userId
    }

    func save(_ session: SportSessionEntry) async throws {
        try await Firestore.firestore()
            .collection("Users/\(userId)/SportSessions")
            .document(session.id)
            .setData(from: session)
    }
}
