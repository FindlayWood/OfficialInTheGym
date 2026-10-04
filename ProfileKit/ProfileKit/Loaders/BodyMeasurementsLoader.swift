//
//  BodyMeasurementsLoader.swift
//  ProfileKit
//
//  Created by Findlay Wood on 03/10/2026.
//
import Foundation

/// Loads the signed-in user's private body measurements. See `BodyMeasurements`.
public protocol BodyMeasurementsLoader {
    func load() async throws -> BodyMeasurements
}
