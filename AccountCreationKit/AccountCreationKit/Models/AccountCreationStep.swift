//
//  AccountCreationStep.swift
//  AccountCreationKit
//
//  Created by Findlay Wood on 09/08/2026.
//

import Foundation

/// The steps of the creation flow, in order.
///
/// This replaced a bare `Int` page index. The review step sends the user back to whichever step is
/// missing something, and `.details` reads where `1` did not.
enum AccountCreationStep: Int, CaseIterable, Identifiable, Hashable {

    /// Display name and username: the two required text fields, together.
    case details

    /// Photo and bio. Both optional.
    case profile

    /// Height, weight and date of birth. All optional.
    case body

    /// Confirm, then create.
    case review

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .details:
            return "Your details"
        case .profile:
            return "Your profile"
        case .body:
            return "About you"
        case .review:
            return "Ready to go"
        }
    }

    var subtitle: String {
        switch self {
        case .details:
            return "How you'll appear to other people in the app."
        case .profile:
            return "Both are optional — you can add them any time."
        case .body:
            return "All optional, and only used to make your training stats mean something."
        case .review:
            return "Check everything over before we create your account."
        }
    }

    /// The label on the bottom button for this step.
    var actionTitle: String {
        switch self {
        case .review:
            return "Create Account"
        default:
            return "Continue"
        }
    }

    var next: AccountCreationStep? {
        AccountCreationStep(rawValue: rawValue + 1)
    }

    var previous: AccountCreationStep? {
        AccountCreationStep(rawValue: rawValue - 1)
    }
}
