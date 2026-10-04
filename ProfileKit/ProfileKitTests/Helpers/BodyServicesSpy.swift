//
//  BodyServicesSpy.swift
//  ProfileKitTests
//
//  Created by Findlay Wood on 03/10/2026.
//

import Foundation
@testable import ProfileKit

/// Every body-screen read and write in one message log. Each result and error
/// is settable, so a test can fail one write and let the next succeed. Never
/// asserts — the test does.
final class BodyServicesSpy: BodyMeasurementsLoader, BodyMeasurementsWriter,
                             WeightLogLoader, WeightEntryWriter, WeightEntryRemover,
                             @unchecked Sendable {

    enum Message: Equatable {
        case loadMeasurements
        case loadLog(limit: Int)
        case saveMeasurements(BodyMeasurements)
        case log(WeightEntry)
        case remove(entryId: String)
    }

    private(set) var receivedMessages: [Message] = []
    var measurements = BodyMeasurements()
    var entries: [WeightEntry] = []
    var loadError: Error?
    var writeError: Error?

    func load() async throws -> BodyMeasurements {
        receivedMessages.append(.loadMeasurements)
        if let loadError { throw loadError }
        return measurements
    }

    func load(limit: Int) async throws -> [WeightEntry] {
        receivedMessages.append(.loadLog(limit: limit))
        if let loadError { throw loadError }
        return entries
    }

    func save(_ measurements: BodyMeasurements) async throws {
        receivedMessages.append(.saveMeasurements(measurements))
        if let writeError { throw writeError }
    }

    func log(_ entry: WeightEntry) async throws {
        receivedMessages.append(.log(entry))
        if let writeError { throw writeError }
    }

    func remove(entryId: String) async throws {
        receivedMessages.append(.remove(entryId: entryId))
        if let writeError { throw writeError }
    }
}
