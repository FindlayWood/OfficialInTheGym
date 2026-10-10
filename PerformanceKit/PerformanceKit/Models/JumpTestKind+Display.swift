//
//  JumpTestKind+Display.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import Foundation

extension JumpTestKind {

    /// An attempt's headline as a number and its unit: height in the chosen
    /// unit, or RSI (unitless, two places) for a drop jump. **Every screen
    /// that shows a result goes through this**, so a drop jump never shows as
    /// a bare height by mistake.
    func headline(of attempt: JumpAttempt, measurement: JumpMeasurement = .cm) -> (value: String, unit: String) {
        switch headline {
        case .height:
            return (measurement.display(centimetres: attempt.height).formatted(.number.precision(.fractionLength(1))), measurement.title)
        case .reactiveStrength:
            return ((attempt.reactiveStrengthIndex ?? 0).formatted(.number.precision(.fractionLength(2))), "RSI")
        }
    }

    /// "41.2 cm" or "RSI 1.84".
    func headlineText(of attempt: JumpAttempt, measurement: JumpMeasurement = .cm) -> String {
        let (value, unit) = headline(of: attempt, measurement: measurement)
        return headline == .reactiveStrength ? "\(unit) \(value)" : "\(value) \(unit)"
    }

    /// The figures behind a headline that is not height: a drop jump's height
    /// and ground contact, "34.1 cm · 0.21 s contact". Nil for a height test.
    func detail(of attempt: JumpAttempt, measurement: JumpMeasurement = .cm) -> String? {
        guard headline == .reactiveStrength else { return nil }
        let height = "\(measurement.display(centimetres: attempt.height).formatted(.number.precision(.fractionLength(1)))) \(measurement.title)"
        guard let contact = attempt.contactTime else { return height }
        return "\(height) · \(contact.formatted(.number.precision(.fractionLength(2)))) s contact"
    }
}
