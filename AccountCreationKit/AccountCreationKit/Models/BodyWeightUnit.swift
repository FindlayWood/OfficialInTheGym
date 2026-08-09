//
//  BodyWeightUnit.swift
//  AccountCreationKit
//
//  Created by Findlay Wood on 09/08/2026.
//

import Foundation

/// How the user enters their bodyweight. **Entry only** — weight is stored as kilograms, matching
/// `WeightUnit.kilograms(_:unit:)` on the stats path, which normalises every logged load to kg
/// before it is written. Two bodyweights that cannot be compared without knowing their units are
/// not much use to a stat.
public enum BodyWeightUnit: String, CaseIterable, Identifiable, Codable {

    case kilograms
    case pounds

    public var id: String { rawValue }

    public var label: String {
        switch self {
        case .kilograms:
            return "kg"
        case .pounds:
            return "lbs"
        }
    }

    // MARK: - Range

    static let kilogramsRange: ClosedRange<Int> = 30...250
    static let poundsRange: ClosedRange<Int> = 66...550

    var range: ClosedRange<Int> {
        switch self {
        case .kilograms:
            return Self.kilogramsRange
        case .pounds:
            return Self.poundsRange
        }
    }

    // MARK: - Conversion

    static let poundsPerKilogram: Double = 2.20462

    static func kilograms(fromPounds pounds: Int) -> Double {
        Double(pounds) / poundsPerKilogram
    }

    static func pounds(fromKilograms kilograms: Double) -> Int {
        Int((kilograms * poundsPerKilogram).rounded())
    }

    /// How a stored weight reads back, in whichever unit was used to enter it.
    static func display(kilograms: Double, in unit: BodyWeightUnit) -> String {
        switch unit {
        case .kilograms:
            return "\(Int(kilograms.rounded())) kg"
        case .pounds:
            return "\(pounds(fromKilograms: kilograms)) lbs"
        }
    }
}
