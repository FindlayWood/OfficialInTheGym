//
//  HeightUnit.swift
//  AccountCreationKit
//
//  Created by Findlay Wood on 09/08/2026.
//

import Foundation

/// How the user enters their height. **Entry only** — height is stored as centimetres, the way
/// `SessionTimeUnit` is entry-only over a stored second count in MyDayKit. Storing the number the
/// user typed alongside a unit would mean every reader had to convert before it could compare two
/// people.
public enum HeightUnit: String, CaseIterable, Identifiable, Codable {

    case centimetres
    case feetInches

    public var id: String { rawValue }

    public var label: String {
        switch self {
        case .centimetres:
            return "cm"
        case .feetInches:
            return "ft / in"
        }
    }

    // MARK: - Range

    /// 3ft to 8ft, in centimetres. Wide enough for anyone and narrow enough that the wheel is usable.
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

    /// How a stored height reads back, in whichever unit was used to enter it.
    static func display(centimetres: Double, in unit: HeightUnit) -> String {
        switch unit {
        case .centimetres:
            return "\(Int(centimetres.rounded())) cm"
        case .feetInches:
            let value = feetAndInches(fromCentimetres: centimetres)
            return "\(value.feet)′ \(value.inches)″"
        }
    }
}
