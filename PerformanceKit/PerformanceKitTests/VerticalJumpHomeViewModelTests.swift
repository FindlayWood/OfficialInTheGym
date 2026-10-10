//
//  VerticalJumpHomeViewModelTests.swift
//  PerformanceKitTests
//
//  Created by Findlay Wood on 10/10/2026.
//

import XCTest
@testable import PerformanceKit

@MainActor
final class VerticalJumpHomeViewModelTests: XCTestCase {

    func test_load_deliversTheBestJump() async {
        let max = VerticalJump(time: .fixed, height: 42)
        let sut = VerticalJumpHomeViewModel(loader: VerticalJumpServicesSpy(maxResult: .success(max)), canRecord: true)

        await sut.load()

        XCTAssertEqual(sut.max, max)
        XCTAssertFalse(sut.isLoading)
    }

    // The result screen decides whether a new jump is a best against what is
    // handed on here. Handing on nothing would make every jump a new best.
    func test_recordNewJump_handsOnTheLoadedBest() async {
        let max = VerticalJump(time: .fixed, height: 42)
        let sut = VerticalJumpHomeViewModel(loader: VerticalJumpServicesSpy(maxResult: .success(max)), canRecord: true)
        var handedOn: [VerticalJump?] = []
        sut.onRecordNewJump = { handedOn.append($0) }
        await sut.load()

        sut.recordNewJump()

        XCTAssertEqual(handedOn, [max])
    }
}
