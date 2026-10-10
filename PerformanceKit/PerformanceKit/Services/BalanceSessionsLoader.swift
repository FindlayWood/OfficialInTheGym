//
//  BalanceSessionsLoader.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import Foundation

/// Every balance session the athlete has saved, in no particular order.
public protocol BalanceSessionsLoader {
    func loadBalanceSessions() async throws -> [BalanceSession]
}
