//
//  JumpInstruction.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import Foundation

/// One numbered step of the jump instructions. Rewritten for the jump engine:
/// a test is three attempts, and tagging is one button that names the event
/// it marks next.
struct JumpInstruction: Hashable {
    let number: Int
    let instruction: String

    static let all: [JumpInstruction] = [
        .init(number: 1, instruction: "Prop the phone about 2m away with your whole body in frame, and leave room around you."),
        .init(number: 2, instruction: "A test is your best of three jumps. Tap Record, jump, and land. Recording stops by itself after 16 seconds."),
        .init(number: 3, instruction: "On the replay, step frame by frame. Tag take-off on the last frame your feet are on the ground."),
        .init(number: 4, instruction: "Tag landing on the first frame your feet are back on the ground. Undo if you got one wrong."),
        .init(number: 5, instruction: "Tap ✓ to keep the jump. Record the next attempt, then Save. Your highest jump is the result.")
    ]
}
