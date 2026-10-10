//
//  PerformanceHomeViewModel.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import Foundation

/// The PERFORMANCE tab's home: the list of tests, and what happens on a tap.
/// Phase D replaces the list with the readiness dashboard.
@MainActor
final class PerformanceHomeViewModel {

    let tools = PerformanceTool.allCases

    var onSelectTool: ((PerformanceTool) -> Void)?

    func select(_ tool: PerformanceTool) {
        onSelectTool?(tool)
    }
}
