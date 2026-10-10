//
//  JumpResultsViewModelTests.swift
//  PerformanceKitTests
//
//  Created by Findlay Wood on 10/10/2026.
//

import XCTest
@testable import PerformanceKit

@MainActor
final class JumpResultsViewModelTests: XCTestCase {

    func test_save_writesTheJumpAndTheNewBest() async {
        let spy = VerticalJumpServicesSpy()
        let max = VerticalJump(time: .fixed.addingTimeInterval(-86_400), height: 40)
        let sut = JumpResultsViewModel(height: 45, max: max, writer: spy, now: { .fixed })

        await sut.save()

        let jump = VerticalJump(time: .fixed, height: 45)
        XCTAssertEqual(spy.receivedMessages, [.write(VerticalJumpSave(jump: jump, best: jump))])
        XCTAssertTrue(sut.saveSucceeded)
    }

    func test_save_keepsTheOldBestWhenTheJumpIsLower() async {
        let spy = VerticalJumpServicesSpy()
        let max = VerticalJump(time: .fixed.addingTimeInterval(-86_400), height: 40)
        let sut = JumpResultsViewModel(height: 30, max: max, writer: spy, now: { .fixed })

        await sut.save()

        let jump = VerticalJump(time: .fixed, height: 30)
        XCTAssertEqual(spy.receivedMessages, [.write(VerticalJumpSave(jump: jump, best: max))])
    }

    // Heights are stored in centimetres. Saving while inches are on screen
    // would otherwise store a 45 cm jump as 17.72.
    func test_save_storesCentimetresWhileShowingInches() async {
        let spy = VerticalJumpServicesSpy()
        let sut = JumpResultsViewModel(height: 45, max: nil, writer: spy, now: { .fixed })
        sut.measurement = .inches

        await sut.save()

        guard case .write(let save) = spy.receivedMessages.first else { return XCTFail("Expected a write") }
        XCTAssertEqual(save.jump.height, 45, accuracy: 0.1)
    }

    func test_measurement_convertsTheShownHeight() {
        let sut = JumpResultsViewModel(height: 45, max: nil, writer: VerticalJumpServicesSpy())

        sut.measurement = .inches

        XCTAssertEqual(sut.height, 17.72, accuracy: 0.0001)
    }

    // The legacy view model left `isSaving` true after a failed write, so
    // "Saving Result..." stayed on screen for good and the jump was lost.
    func test_save_stopsSavingOnFailureSoItCanBeRetried() async {
        let sut = JumpResultsViewModel(height: 45, max: nil, writer: VerticalJumpServicesSpy(writeError: NSError(domain: "test", code: 0)))

        await sut.save()

        XCTAssertFalse(sut.isSaving)
        XCTAssertFalse(sut.saveSucceeded)
    }
}
