//
//  BodyMeasure.swift
//  AccountCreationKit
//
//  Created by Findlay Wood on 09/08/2026.
//

import Foundation

/// Which body measure is being edited — routes the single `.sheet(item:)` on `BodyStepView` to the
/// right picker, the way `SessionSetEditTarget` does on the session overlay.
enum BodyMeasure: String, Identifiable {
    case height
    case weight
    case dateOfBirth

    var id: String { rawValue }
}
