//
//  InjuryChartBands.swift
//  StatsKit
//
//  Created by Findlay Wood on 10/11/2026.
//

import Foundation

/// Where injuries fall on a chart's x-axis: for each injury overlapping `dayKeys`, the first
/// and last index it covers. **The one place a chart works this out**, so every chart that
/// shades injuries shades the same days.
enum InjuryChartBands {

    static func bands(for injuries: [StatsInjury], over dayKeys: [String], today: Date = .now) -> [ClosedRange<Int>] {
        guard !dayKeys.isEmpty else { return [] }
        let indexByKey = Dictionary(dayKeys.enumerated().map { ($0.element, $0.offset) }, uniquingKeysWith: { first, _ in first })
        return injuries.compactMap { injury in
            let covered = injury.dayKeys(today: today).compactMap { indexByKey[$0] }
            guard let first = covered.min(), let last = covered.max() else { return nil }
            return first...last
        }
        .sorted { $0.lowerBound < $1.lowerBound }
    }
}
