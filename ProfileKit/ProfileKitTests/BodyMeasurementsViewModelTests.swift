//
//  BodyMeasurementsViewModelTests.swift
//  ProfileKitTests
//
//  Created by Findlay Wood on 03/10/2026.
//

import XCTest
@testable import ProfileKit

@MainActor
final class BodyMeasurementsViewModelTests: XCTestCase {

    // MARK: - Load

    func test_load_deliversMeasurementsAndEntries() async {
        let sut = makeSUT(measurements: BodyMeasurements(heightCentimetres: 180), entries: [entry("2026-10-01", 80)])

        await sut.viewModel.load()

        XCTAssertEqual(sut.viewModel.loadState, .loaded)
        XCTAssertEqual(sut.viewModel.measurements.heightCentimetres ?? 0, 180, accuracy: 0.001)
        XCTAssertEqual(sut.viewModel.entries, [entry("2026-10-01", 80)])
    }

    // A failed read must not look like an empty log to someone who has logged
    // for months.
    func test_load_deliversFailedRatherThanEmptyOnError() async {
        let sut = makeSUT()
        sut.spy.loadError = anyError

        await sut.viewModel.load()

        XCTAssertEqual(sut.viewModel.loadState, .failed)
    }

    // MARK: - Height and date of birth

    // A sheet opened and closed without a change must not write the same
    // values back.
    func test_saveMeasurementsIfChanged_writesNothingWhenUnchanged() async {
        let sut = makeSUT(measurements: BodyMeasurements(heightCentimetres: 180))
        await sut.viewModel.load()

        await sut.viewModel.saveMeasurementsIfChanged()

        XCTAssertFalse(sut.spy.receivedMessages.contains { if case .saveMeasurements = $0 { true } else { false } })
    }

    func test_saveMeasurementsIfChanged_writesTheChangedMeasurements() async {
        let sut = makeSUT(measurements: BodyMeasurements(heightCentimetres: 180))
        await sut.viewModel.load()
        sut.viewModel.measurements.heightCentimetres = nil

        await sut.viewModel.saveMeasurementsIfChanged()

        XCTAssertEqual(sut.spy.receivedMessages.last, .saveMeasurements(BodyMeasurements()))
    }

    // Nothing on screen may claim a value the server never took.
    func test_saveMeasurementsIfChanged_revertsAndReportsOnFailure() async {
        let sut = makeSUT(measurements: BodyMeasurements(heightCentimetres: 180))
        await sut.viewModel.load()
        sut.spy.writeError = anyError
        sut.viewModel.measurements.heightCentimetres = 190

        await sut.viewModel.saveMeasurementsIfChanged()

        XCTAssertEqual(sut.viewModel.measurements.heightCentimetres ?? 0, 180, accuracy: 0.001)
        XCTAssertNotNil(sut.viewModel.errorMessage)
    }

    // MARK: - Weight

    func test_logWeight_writesTodaysEntryAndShowsItFirst() async {
        let sut = makeSUT(entries: [entry("2026-10-01", 80)])
        await sut.viewModel.load()

        await sut.viewModel.logWeight(kilograms: 79.5, unit: .kilograms)

        let today = WeightEntry(id: "2026-10-03", date: midnight("2026-10-03"), weightKilograms: 79.5, unit: .kilograms)
        XCTAssertEqual(sut.spy.receivedMessages.last, .log(today))
        XCTAssertEqual(sut.viewModel.entries.map(\.id), ["2026-10-03", "2026-10-01"])
        XCTAssertTrue(sut.viewModel.hasLoggedToday)
    }

    // One entry per day: a second log the same day replaces the first rather
    // than drawing two points on one date.
    func test_logWeight_replacesAnEntryFromTheSameDay() async {
        let sut = makeSUT(entries: [entry("2026-10-03", 81), entry("2026-10-01", 80)])
        await sut.viewModel.load()

        await sut.viewModel.logWeight(kilograms: 80.4, unit: .kilograms)

        XCTAssertEqual(sut.viewModel.entries.map(\.id), ["2026-10-03", "2026-10-01"])
        XCTAssertEqual(sut.viewModel.entries.first?.weightKilograms ?? 0, 80.4, accuracy: 0.001)
    }

    func test_logWeight_putsTheLogBackOnFailure() async {
        let sut = makeSUT(entries: [entry("2026-10-01", 80)])
        await sut.viewModel.load()
        sut.spy.writeError = anyError

        await sut.viewModel.logWeight(kilograms: 79.5, unit: .kilograms)

        XCTAssertEqual(sut.viewModel.entries, [entry("2026-10-01", 80)])
        XCTAssertNotNil(sut.viewModel.errorMessage)
    }

    func test_deleteEntry_removesItAndAsksTheServer() async {
        let sut = makeSUT(entries: [entry("2026-10-02", 81), entry("2026-10-01", 80)])
        await sut.viewModel.load()

        await sut.viewModel.deleteEntry(entry("2026-10-02", 81))

        XCTAssertEqual(sut.spy.receivedMessages.last, .remove(entryId: "2026-10-02"))
        XCTAssertEqual(sut.viewModel.entries.map(\.id), ["2026-10-01"])
    }

    func test_deleteEntry_restoresItOnFailure() async {
        let sut = makeSUT(entries: [entry("2026-10-02", 81)])
        await sut.viewModel.load()
        sut.spy.writeError = anyError

        await sut.viewModel.deleteEntry(entry("2026-10-02", 81))

        XCTAssertEqual(sut.viewModel.entries.map(\.id), ["2026-10-02"])
    }

    // MARK: - Unit

    func test_weightUnit_followsTheLatestEntryThenThePreferenceThenKilograms() async {
        let sut = makeSUT(measurements: BodyMeasurements(weightUnit: .pounds))
        XCTAssertEqual(sut.viewModel.weightUnit, .kilograms)

        await sut.viewModel.load()
        XCTAssertEqual(sut.viewModel.weightUnit, .pounds)

        await sut.viewModel.logWeight(kilograms: 80, unit: .kilograms)
        XCTAssertEqual(sut.viewModel.weightUnit, .kilograms)
    }

    // MARK: - Helpers

    private func makeSUT(
        measurements: BodyMeasurements = BodyMeasurements(),
        entries: [WeightEntry] = []
    ) -> (viewModel: BodyMeasurementsViewModel, spy: BodyServicesSpy) {
        let spy = BodyServicesSpy()
        spy.measurements = measurements
        spy.entries = entries
        let viewModel = BodyMeasurementsViewModel(
            measurementsLoader: spy,
            measurementsWriter: spy,
            logLoader: spy,
            entryWriter: spy,
            entryRemover: spy,
            now: { fixedNow }
        )
        return (viewModel, spy)
    }

    private func entry(_ key: String, _ kilograms: Double) -> WeightEntry {
        WeightEntry(id: key, date: midnight(key), weightKilograms: kilograms, unit: .kilograms)
    }

    private func midnight(_ key: String) -> Date {
        ISO8601DateFormatter().date(from: "\(key)T00:00:00Z")!
    }
}

/// 3 October 2026, 14:00 UTC.
private let fixedNow = ISO8601DateFormatter().date(from: "2026-10-03T14:00:00Z")!

private let anyError = NSError(domain: "test", code: 0)
