//
//  MaxVerticalJumpLoader.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import Foundation

/// The athlete's best jump, or nil if they have never saved one.
public protocol MaxVerticalJumpLoader {
    func loadMax() async throws -> VerticalJump?
}
