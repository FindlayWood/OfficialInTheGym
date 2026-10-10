//
//  JumpTestFields.swift
//  InTheGym
//
//  Created by Findlay Wood on 10/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//
import FirebaseFirestore
import PerformanceKit

/// The fields of a jump-test session document. **The writer and the loader
/// both use this**, so what is written is what is read.
///
/// - `kind`: `JumpTestKind.rawValue`, which is why a case is never renamed.
/// - `date`: a timestamp.
/// - `attempts`: an array of `{ height, flightTime?, contactTime? }`, heights in
///   centimetres and times in seconds; an absent time is left out, not null.
/// - `bodyMass`: kilograms at the time of the test, left out when unknown. A
///   session's power is worked out from it, so it does not move with later
///   weigh-ins.
/// - `boxHeight`: centimetres, a drop jump's box; left out for other tests.
/// - `bestHeight`: the best attempt's height, **written for queries only**
///   (the fatigue check's recent max, a coach's summary) and never read back.
///   The app always works the best out from `attempts`.
enum JumpTestFields {

    static func fields(of session: JumpTestSession) -> [String: Any] {
        var fields: [String: Any] = [
            "kind": session.kind.rawValue,
            "date": session.date,
            "attempts": session.attempts.map(fields(of:))
        ]
        if let best = session.best?.height {
            fields["bestHeight"] = best
        }
        if let bodyMass = session.bodyMass {
            fields["bodyMass"] = bodyMass
        }
        if let boxHeight = session.boxHeight {
            fields["boxHeight"] = boxHeight
        }
        return fields
    }

    static func session(from document: DocumentSnapshot) -> JumpTestSession? {
        guard let rawKind = document.get("kind") as? String,
              let kind = JumpTestKind(rawValue: rawKind),
              let date = (document.get("date") as? Timestamp)?.dateValue(),
              let rawAttempts = document.get("attempts") as? [[String: Any]] else {
            return nil
        }
        let attempts = rawAttempts.compactMap(attempt(from:))
        guard attempts.count == rawAttempts.count else { return nil }
        return JumpTestSession(
            id: document.documentID,
            kind: kind,
            date: date,
            attempts: attempts,
            bodyMass: (document.get("bodyMass") as? NSNumber)?.doubleValue,
            boxHeight: (document.get("boxHeight") as? NSNumber)?.doubleValue
        )
    }

    private static func fields(of attempt: JumpAttempt) -> [String: Any] {
        var fields: [String: Any] = ["height": attempt.height]
        if let flightTime = attempt.flightTime { fields["flightTime"] = flightTime }
        if let contactTime = attempt.contactTime { fields["contactTime"] = contactTime }
        return fields
    }

    private static func attempt(from fields: [String: Any]) -> JumpAttempt? {
        guard let height = (fields["height"] as? NSNumber)?.doubleValue else { return nil }
        return JumpAttempt(
            height: height,
            flightTime: (fields["flightTime"] as? NSNumber)?.doubleValue,
            contactTime: (fields["contactTime"] as? NSNumber)?.doubleValue
        )
    }
}
