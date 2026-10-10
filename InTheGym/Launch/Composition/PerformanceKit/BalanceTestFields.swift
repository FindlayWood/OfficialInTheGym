//
//  BalanceTestFields.swift
//  InTheGym
//
//  Created by Findlay Wood on 10/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//
import FirebaseFirestore
import PerformanceKit

/// The fields of a balance session document. **The writer and the loader both
/// use this.**
///
/// - `date`: a timestamp.
/// - `condition`: `BalanceCondition.rawValue`, `"eyesOpen"` / `"eyesClosed"`.
/// - `attempts`: an array of `{ sway, duration, side }`, sway in mg, duration
///   in seconds, side `"left"` / `"right"`.
enum BalanceTestFields {

    static func fields(of session: BalanceSession) -> [String: Any] {
        [
            "date": session.date,
            "condition": session.condition.rawValue,
            "attempts": session.attempts.map { ["sway": $0.sway, "duration": $0.duration, "side": $0.side.rawValue] }
        ]
    }

    static func session(from document: DocumentSnapshot) -> BalanceSession? {
        guard let date = (document.get("date") as? Timestamp)?.dateValue(),
              let condition = (document.get("condition") as? String).flatMap(BalanceCondition.init(rawValue:)),
              let rawAttempts = document.get("attempts") as? [[String: Any]] else {
            return nil
        }
        let attempts = rawAttempts.compactMap { fields -> BalanceAttempt? in
            guard let sway = (fields["sway"] as? NSNumber)?.doubleValue,
                  let duration = (fields["duration"] as? NSNumber)?.doubleValue,
                  let side = (fields["side"] as? String).flatMap(JumpSide.init(rawValue:)) else { return nil }
            return BalanceAttempt(sway: sway, duration: duration, side: side)
        }
        guard attempts.count == rawAttempts.count else { return nil }
        return BalanceSession(id: document.documentID, date: date, condition: condition, attempts: attempts)
    }
}
