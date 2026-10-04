//
//  BodyMeasurementsWriter.swift
//  ProfileKit
//
//  Created by Findlay Wood on 03/10/2026.
//
import Foundation

/// Saves height, height unit and date of birth. A `nil` clears the field
/// rather than being skipped, because Clear on a sheet is the only way back to
/// "not set", and it has to reach the server.
///
/// `weightUnit` is not written: it follows the latest weight entry server-side.
public protocol BodyMeasurementsWriter {
    func save(_ measurements: BodyMeasurements) async throws
}
