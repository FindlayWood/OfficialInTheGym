//
//  JumpInstruction.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import Foundation

/// One numbered step of the jump instructions. The copy is the legacy
/// `JumpInstructionsViewController`'s, unchanged.
struct JumpInstruction: Hashable {
    let number: Int
    let instruction: String

    static let all: [JumpInstruction] = [
        .init(number: 1, instruction: "Find some space gor you to record your jump. Enough space around so you wont bash off anything and around 2m away from the camera."),
        .init(number: 2, instruction: "When recording starts you have 16 seconds to jump and land. It is important that both your take off and landing are captured on the recording."),
        .init(number: 3, instruction: "Once you have recorded your jump you will then be shown the tagging screen. Here you must tag your take off and landing."),
        .init(number: 4, instruction: "To tag your take off, select last frame with your feet touching the ground before you jump. (you can't select the very first frame of the video)"),
        .init(number: 5, instruction: "To tag your landing, select first frame with your feet touching the ground after you jump."),
        .init(number: 6, instruction: "Once you have tagged your jump (take off must come before landing) then you will see a right arrow button in the top right. Tap this to see your results.")
    ]
}
