//
//  BodyMeasurements.swift
//  ProfileKit
//
//  Created by Findlay Wood on 03/10/2026.
//
import Foundation

/// The private body facts on `Users/{uid}`, all optional: height, the unit to
/// read it in, date of birth, and the weight unit preference.
///
/// **Weight itself is not here.** It is a log (`WeightEntry`), and the latest
/// entry is copied onto the user document by the `syncLatestWeight` function
/// rather than written by the app. `weightUnit` is read only, as the
/// preference to show weights in until the user has logged one.
///
/// Never on `ProfileHeader`, and never in `Profiles/{uid}`. These are the
/// fields that projection exists to keep private.
public struct BodyMeasurements: Equatable, Sendable {
    public var heightCentimetres: Double?
    public var heightUnit: ProfileHeightUnit?
    public var dateOfBirth: Date?
    public var weightUnit: ProfileWeightUnit?

    public init(
        heightCentimetres: Double? = nil,
        heightUnit: ProfileHeightUnit? = nil,
        dateOfBirth: Date? = nil,
        weightUnit: ProfileWeightUnit? = nil
    ) {
        self.heightCentimetres = heightCentimetres
        self.heightUnit = heightUnit
        self.dateOfBirth = dateOfBirth
        self.weightUnit = weightUnit
    }
}
