//
//  ProfileWeightUnit.swift
//  ProfileKit
//
//  Created by Findlay Wood on 03/10/2026.
//
import Foundation

/// How the user enters and reads their bodyweight. **Entry only**: weight is
/// stored in kilograms, as everywhere else. ProfileKit's copy of
/// AccountCreationKit's `BodyWeightUnit`, **kept in step with it**. The raw
/// values are what `createAccount` stores, so they must not change.
///
/// **One difference, deliberately:** a logged weight carries one decimal place.
/// Signup takes whole numbers because a single number captured once does not
/// warrant more. A log is read as a trend, and a 0.4 kg week is the trend.
public enum ProfileWeightUnit: String, CaseIterable, Identifiable, Sendable {

    case kilograms
    case pounds

    public var id: String { rawValue }

    var label: String {
        switch self {
        case .kilograms: "kg"
        case .pounds: "lbs"
        }
    }

    /// Whole-number part of the wheel, the same span as signup's.
    var wholeRange: ClosedRange<Int> {
        switch self {
        case .kilograms: 30...250
        case .pounds: 66...550
        }
    }

    static let poundsPerKilogram: Double = 2.20462

    /// The stored kilograms in this unit, to one decimal place.
    func value(fromKilograms kilograms: Double) -> Double {
        let value = self == .kilograms ? kilograms : kilograms * Self.poundsPerKilogram
        return (value * 10).rounded() / 10
    }

    func kilograms(from value: Double) -> Double {
        self == .kilograms ? value : value / Self.poundsPerKilogram
    }

    func display(kilograms: Double) -> String {
        let value = value(fromKilograms: kilograms)
        let text = value.truncatingRemainder(dividingBy: 1) == 0
            ? String(Int(value))
            : String(format: "%.1f", value)
        return "\(text) \(label)"
    }
}
