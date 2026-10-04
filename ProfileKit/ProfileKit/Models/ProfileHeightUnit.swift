//
//  ProfileHeightUnit.swift
//  ProfileKit
//
//  Created by Findlay Wood on 03/10/2026.
//
import Foundation

/// How the user enters and reads their height. **Entry only**: height is
/// stored in centimetres. ProfileKit's copy of AccountCreationKit's
/// `HeightUnit`, **kept in step with it**. The raw values are what
/// `createAccount` validates and stores in `Users.heightUnit`, so they must
/// not change.
public enum ProfileHeightUnit: String, CaseIterable, Identifiable, Sendable {

    case centimetres
    case feetInches

    public var id: String { rawValue }

    var label: String {
        switch self {
        case .centimetres: "cm"
        case .feetInches: "ft / in"
        }
    }

    // MARK: - Range

    static let minimumCentimetres: Int = 90
    static let maximumCentimetres: Int = 250
    static let feetRange: ClosedRange<Int> = 2...8
    static let inchesRange: ClosedRange<Int> = 0...11

    // MARK: - Conversion

    static func centimetres(fromFeet feet: Int, inches: Int) -> Double {
        (Double(feet) * 30.48) + (Double(inches) * 2.54)
    }

    static func feetAndInches(fromCentimetres centimetres: Double) -> (feet: Int, inches: Int) {
        let totalInches = (centimetres / 2.54).rounded()
        var feet = Int(totalInches) / 12
        var inches = Int(totalInches) % 12
        // 5ft 12in is not a height anybody writes.
        if inches == 12 {
            feet += 1
            inches = 0
        }
        return (feet, inches)
    }

    static func display(centimetres: Double, in unit: ProfileHeightUnit) -> String {
        switch unit {
        case .centimetres:
            return "\(Int(centimetres.rounded())) cm"
        case .feetInches:
            let value = feetAndInches(fromCentimetres: centimetres)
            return "\(value.feet)′ \(value.inches)″"
        }
    }
}
