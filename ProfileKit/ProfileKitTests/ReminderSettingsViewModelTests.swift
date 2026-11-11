//
//  ReminderSettingsViewModelTests.swift
//  ProfileKitTests
//
//  Created by Findlay Wood on 09/11/2026.
//

import XCTest
@testable import ProfileKit

@MainActor
final class ReminderSettingsViewModelTests: XCTestCase {

    func test_init_deliversStoredSettings() {
        let (sut, _) = makeSUT(stored: allOff)

        XCTAssertEqual(sut.settings, allOff)
    }

    // iOS shows its prompt once. Asking at the moment a reminder is switched on is the only
    // time the user has a reason to say yes.
    func test_setOn_asksPermissionBeforeTurningAReminderOnForTheFirstTime() async {
        let (sut, service) = makeSUT(status: .notAsked, grants: true)
        await sut.refreshPermission()

        await sut.setOn(true, for: .checkIn)

        XCTAssertTrue(service.receivedMessages.contains(.requestPermission))
        XCTAssertTrue(sut.settings.checkIn.isOn)
    }

    // A switch that reads on while nothing can be delivered is a promise the app cannot keep.
    func test_setOn_leavesTheReminderOffWhenPermissionIsRefused() async {
        let (sut, service) = makeSUT(status: .notAsked, grants: false)
        await sut.refreshPermission()

        await sut.setOn(true, for: .checkIn)

        XCTAssertFalse(sut.settings.checkIn.isOn)
        XCTAssertFalse(service.receivedMessages.contains { if case .save = $0 { return true } else { return false } })
        XCTAssertTrue(sut.showsPermissionBanner)
    }

    func test_setOn_doesNotAskAgainOnceAllowed() async {
        let (sut, service) = makeSUT(status: .allowed, grants: true)
        await sut.refreshPermission()

        await sut.setOn(true, for: .dayRating)

        XCTAssertFalse(service.receivedMessages.contains(.requestPermission))
        XCTAssertTrue(sut.settings.dayRating.isOn)
    }

    func test_setTime_savesTheNewTime() {
        let (sut, service) = makeSUT()

        sut.setTime(hour: 7, minute: 30, for: .checkIn)

        var expected = allOff
        expected.checkIn.hour = 7
        expected.checkIn.minute = 30
        XCTAssertEqual(service.receivedMessages.last, .save(expected))
    }

    func test_toggle_removesAChosenWeekday() {
        let (sut, _) = makeSUT()

        sut.toggle(.sunday, for: .checkIn)

        XCTAssertFalse(sut.settings.checkIn.weekdays.contains(.sunday))
    }

    // A reminder on with no days reads as set and never fires.
    func test_toggle_keepsTheLastWeekday() {
        var stored = allOff
        stored.checkIn.weekdays = [.monday]
        let (sut, service) = makeSUT(stored: stored)

        sut.toggle(.monday, for: .checkIn)

        XCTAssertEqual(sut.settings.checkIn.weekdays, [.monday])
        XCTAssertEqual(service.receivedMessages, [.load])
    }

    // MARK: - Helpers

    private func makeSUT(
        stored: ProfileReminderSettings? = nil,
        status: ProfileReminderPermission = .allowed,
        grants: Bool = true,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: ReminderSettingsViewModel, service: ReminderSettingsServiceSpy) {
        let service = ReminderSettingsServiceSpy(stored: stored ?? allOff, status: status, grants: grants)
        let sut = ReminderSettingsViewModel(service: service)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(service, file: file, line: line)
        return (sut, service)
    }

    private var allOff: ProfileReminderSettings {
        ProfileReminderSettings(
            checkIn: ProfileReminderSetting(isOn: false, hour: 8, minute: 0, weekdays: Set(ProfileWeekday.allCases)),
            dayRating: ProfileReminderSetting(isOn: false, hour: 20, minute: 0, weekdays: Set(ProfileWeekday.allCases))
        )
    }
}
