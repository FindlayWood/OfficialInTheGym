//
//  PreviewBodyServices.swift
//  ProfileKit
//
//  Created by Findlay Wood on 03/10/2026.
//
import Foundation

/// Preview conformer for the body screen: a height, no date of birth, and a
/// few weeks of weight entries so previews show the trend line. Every write
/// succeeds and stores nothing.
public final class PreviewBodyServices: BodyMeasurementsLoader, BodyMeasurementsWriter,
                                        WeightLogLoader, WeightEntryWriter, WeightEntryRemover,
                                        @unchecked Sendable {
    public init() {}

    public func load() async throws -> BodyMeasurements {
        BodyMeasurements(heightCentimetres: 180, heightUnit: .centimetres, weightUnit: .kilograms)
    }

    public func load(limit: Int) async throws -> [WeightEntry] {
        (0..<min(limit, 8)).map { week in
            let date = Date.now.addingTimeInterval(-Double(week) * 7 * 86_400)
            return WeightDay.entry(kilograms: 82 - Double(week) * 0.4, unit: .kilograms, on: date)
        }
    }

    public func save(_ measurements: BodyMeasurements) async throws {}

    public func log(_ entry: WeightEntry) async throws {}

    public func remove(entryId: String) async throws {}
}
