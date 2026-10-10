//
//  JumpInstruction.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import Foundation

/// One numbered step of a jump test's instructions. Every jump test shares
/// the steps for filming and tagging; the second step is the test's own
/// technique (`JumpTestKind.technique`).
struct JumpInstruction: Hashable {
    let number: Int
    let instruction: String

    static func all(for kind: JumpTestKind) -> [JumpInstruction] {
        [
            "Prop the phone about 2m away with your whole body in frame, and leave room around you.",
            kind.technique,
            "A test is your best of \(kind.attempts). Tap Record, jump, and land. Recording stops by itself after 16 seconds.",
            "On the replay, step frame by frame. Tag take-off on the last frame your feet are on the ground.",
            "Tag landing on the first frame your feet are back on the ground. Undo if you got one wrong.",
            "Tap ✓ to keep the jump. Record the next attempt, then Save. Your highest jump is the result."
        ]
        .enumerated()
        .map { JumpInstruction(number: $0.offset + 1, instruction: $0.element) }
    }
}
