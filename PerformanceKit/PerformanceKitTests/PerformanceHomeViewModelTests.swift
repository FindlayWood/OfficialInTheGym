//
//  PerformanceHomeViewModelTests.swift
//  PerformanceKitTests
//
//  Created by Findlay Wood on 10/10/2026.
//

import XCTest
@testable import PerformanceKit

@MainActor
final class PerformanceHomeViewModelTests: XCTestCase {

    func test_tools_deliversEveryTestInOrder() {
        let sut = PerformanceHomeViewModel()

        XCTAssertEqual(sut.tools, [.cmj, .verticalJump])
    }

    func test_select_forwardsTheTool() {
        let sut = PerformanceHomeViewModel()
        var selected: [PerformanceTool] = []
        sut.onSelectTool = { selected.append($0) }

        sut.select(.verticalJump)

        XCTAssertEqual(selected, [.verticalJump])
    }
}
