//
//  CMJSnapshotLoader.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import Foundation

/// The athlete's CMJ summary, or nil if there is none **or it could not be
/// read**. A tracked session is recorded without one rather than not at all,
/// as it always was.
public protocol CMJSnapshotLoader {
    func loadCMJ() async -> CMJSnapshot?
}
