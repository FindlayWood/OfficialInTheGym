//
//  JumpPower.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import Foundation

/// Peak power from a countermovement jump, by the **Sayers equation**:
/// watts = 60.7 × height (cm) + 45.3 × body mass (kg) − 2055. It estimates what
/// a force plate would measure from what a camera can, and is the standard
/// field estimate. It is meant for jumps without arm swing, which is why only
/// CMJ shows it (`JumpTestKind.estimatesPower`).
///
/// Per kilogram as well, because absolute power rises with body mass and the
/// relative figure is the one comparable across athletes and across a weight
/// change.
struct JumpPower: Equatable {

    let watts: Double
    let wattsPerKilogram: Double

    init?(heightCentimetres height: Double, bodyMassKilograms mass: Double) {
        guard height > 0, mass > 0 else { return nil }
        let watts = 60.7 * height + 45.3 * mass - 2055
        guard watts > 0 else { return nil }
        self.watts = watts
        self.wattsPerKilogram = watts / mass
    }
}
