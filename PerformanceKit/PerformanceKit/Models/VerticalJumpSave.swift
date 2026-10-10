//
//  VerticalJumpSave.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import Foundation

/// What saving a jump writes: the jump itself, for the history, and the
/// athlete's best once it is counted. The best is worked out here, where the
/// current best is already loaded, so the writers only store what they are
/// given.
public struct VerticalJumpSave: Equatable, Sendable {
    public let jump: VerticalJump
    public let best: VerticalJump

    public init(jump: VerticalJump, best: VerticalJump) {
        self.jump = jump
        self.best = best
    }
}
