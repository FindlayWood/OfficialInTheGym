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
        return numbered(steps)
    }

    /// The balance test's steps.
    static let balance: [JumpInstruction] = numbered([
        "Take your shoes off and stand somewhere flat and clear.",
        "Hold the phone flat against the middle of your chest with both hands, screen facing out. Keep it there the whole time.",
        "Choose eyes open or eyes closed for the session. Eyes closed is the harder, more telling test.",
        "Tap Start and lift one foot. After a five-second countdown you'll hear a tone: hold as still as you can for 30 seconds until the second tone.",
        "If you have to put your foot down, tap Foot down. The stand is kept but doesn't count toward your best.",
        "Do two stands on each leg, then Save. Lower sway is steadier."
    ])

    private static func numbered(_ steps: [String]) -> [JumpInstruction] {
        steps.enumerated().map { JumpInstruction(number: $0.offset + 1, instruction: $0.element) }
    }
}
