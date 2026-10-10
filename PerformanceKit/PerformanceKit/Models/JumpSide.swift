//
//  JumpSide.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import Foundation

/// Which leg an attempt was on, for a single-leg test. `rawValue` is stored on
/// the attempt, so a case is never renamed.
public enum JumpSide: String, Sendable, CaseIterable {
    case left
    case right

    var title: String {
        switch self {
        case .left: "Left"
        case .right: "Right"
        }
    }

    var initial: String {
        switch self {
        case .left: "L"
        case .right: "R"
        }
    }
}
