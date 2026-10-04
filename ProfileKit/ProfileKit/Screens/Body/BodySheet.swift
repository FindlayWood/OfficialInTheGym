//
//  BodySheet.swift
//  ProfileKit
//
//  Created by Findlay Wood on 03/10/2026.
//
import SwiftUI

/// Which sheet the body screen is showing. It routes the single
/// `.sheet(item:)`, as `BodyMeasure` does on the signup body step.
enum BodySheet: String, Identifiable {
    case height
    case dateOfBirth
    case logWeight

    var id: String { rawValue }

    /// Height and date of birth save when their sheet closes. The weight sheet
    /// saves on its own Log button, so closing it otherwise logs nothing.
    var savesOnDismiss: Bool {
        self != .logWeight
    }

    var detentHeight: CGFloat {
        switch self {
        case .height, .logWeight: 380
        case .dateOfBirth: 340
        }
    }
}
