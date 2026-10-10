//
//  LegacyVerticalJumpSessionsLoader.swift
//  InTheGym
//
//  Created by Findlay Wood on 10/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//
import FirebaseFirestore
import PerformanceKit

/// Vertical jumps saved before the jump engine, at
/// `VerticalJump/{uid}/Results/{id}`, each a single `{ time, height }`, read as
/// sessions of one attempt with no times. Other tests have no legacy data and
/// get none.
///
/// Read-only: nothing writes here now. The legacy best-jump document beside it
/// (`VerticalJump/{uid}`) is not read; the best is worked out from the history,
/// which these results are part of.
///
/// A session's id is the result's document id prefixed `legacy-`, so it can
/// never collide with an engine session's.
struct LegacyVerticalJumpSessionsLoader: JumpTestSessionsLoader {

    let userId: String

    func loadSessions(_ kind: JumpTestKind) async throws -> [JumpTestSession] {
        guard kind == .verticalJump else { return [] }
        let snapshot = try await Firestore.firestore()
            .collection("VerticalJump/\(userId)/Results")
            .getDocuments()
        return snapshot.documents.compactMap { document in
            guard let time = (document.get("time") as? Timestamp)?.dateValue(),
                  let height = (document.get("height") as? NSNumber)?.doubleValue else {
                print("❌ Skipping legacy jump \(document.documentID)")
                return nil
            }
            return JumpTestSession(
                id: "legacy-\(document.documentID)",
                kind: .verticalJump,
                date: time,
                attempts: [JumpAttempt(height: height, flightTime: nil, contactTime: nil)]
            )
        }
    }
}
