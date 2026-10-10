//
//  PreviousJumpsViewModelTests.swift
//  PerformanceKitTests
//
//  Created by Findlay Wood on 10/10/2026.
//

import XCTest
@testable import PerformanceKit

@MainActor
final class PreviousJumpsViewModelTests: XCTestCase {

    func test_sortedJumps_deliversNewestFirstByDefault() async {
        let (old, new) = (jump(daysAgo: 2, height: 50), jump(daysAgo: 0, height: 30))
        let sut = PreviousJumpsViewModel(loader: VerticalJumpServicesSpy(jumpsResult: .success([old, new])))

        await sut.load()

        XCTAssertEqual(sut.sortedJumps, [new, old])
    }

    func test_sortedJumps_deliversHighestFirstWhenSortedByHeight() async {
        let (old, new) = (jump(daysAgo: 2, height: 50), jump(daysAgo: 0, height: 30))
        let sut = PreviousJumpsViewModel(loader: VerticalJumpServicesSpy(jumpsResult: .success([new, old])))
        await sut.load()

        sut.sortByDate(false)

        XCTAssertEqual(sut.sortedJumps, [old, new])
    }

    func test_load_keepsNothingAndStopsLoadingOnFailure() async {
        let sut = PreviousJumpsViewModel(loader: VerticalJumpServicesSpy(jumpsResult: .failure(NSError(domain: "test", code: 0))))

        await sut.load()

        XCTAssertEqual(sut.jumps, [])
        XCTAssertFalse(sut.isLoading)
    }

    // MARK: - Helpers

    private func jump(daysAgo: Double, height: Double) -> VerticalJump {
        VerticalJump(time: .fixed.addingTimeInterval(-daysAgo * 86_400), height: height)
    }
}
