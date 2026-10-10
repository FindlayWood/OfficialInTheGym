//
//  JumpInstruction.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import Foundation

/// One numbered step of a jump test's instructions. Every jump test shares
/// the steps for filming and saving; the technique and the tagging steps are
/// the test's own (`JumpTestKind.technique`, `.tagSteps`).
struct JumpInstruction: Hashable {
    let number: Int
    let instruction: String

    static func all(for kind: JumpTestKind) -> [JumpInstruction] {
        let steps = ["Prop the phone about 2m away with your whole body in frame, and leave room around you."]
            + [kind.technique]
            + ["A test is your best of \(kind.attempts). Tap Record, jump, and land. Recording stops by itself after 16 seconds."]
            + kind.tagSteps
            + ["Tap ✓ to keep the jump. Record the next attempt, then Save. Your best is the result."]
        return steps.enumerated().map { JumpInstruction(number: $0.offset + 1, instruction: $0.element) }
    }
}
