//
//  VerticalJumpWriter.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import Foundation

/// Saves a jump. Today that is two writes, the jump into the history and the
/// best, by two writers behind one decorator in the composition root.
public protocol VerticalJumpWriter {
    func write(_ save: VerticalJumpSave) async throws
}
