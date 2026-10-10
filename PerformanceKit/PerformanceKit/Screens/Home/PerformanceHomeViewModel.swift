//
//  PerformanceHomeViewModel.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import Foundation

/// Performance Center's home: the list of tools, and what happens on a tap.
///
/// Whose Performance Center this is matters for one tool only. A coach viewing
/// an athlete's centre does not see their journal (`PerformanceTool.isOwnerOnly`).
/// The legacy screen compared the athlete's id against `UserDefaults.currentUser`
/// itself; here the two ids are injected, so the rule is testable.
@MainActor
final class PerformanceHomeViewModel {

    let tools: [PerformanceTool]

    var onSelectTool: ((PerformanceTool) -> Void)?

    init(currentUserId: String, athleteId: String) {
        let isOwn = currentUserId == athleteId
        self.tools = PerformanceTool.allCases.filter { isOwn || !$0.isOwnerOnly }
    }

    func select(_ tool: PerformanceTool) {
        onSelectTool?(tool)
    }
}
