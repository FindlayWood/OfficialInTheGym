//
//  WorkloadsLoader.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import Foundation

/// The athlete's whole workload log, in no particular order.
public protocol WorkloadsLoader {
    func loadWorkloads() async throws -> [Workload]
}
