//
//  UsernameValidity.swift
//  AccountCreationKit
//
//  Created by Findlay Wood on 09/08/2026.
//

import Foundation

enum UsernameValidity {
    case idle
    case tooShort
    case checking
    case taken
    case valid
    case invalid

    /// The availability lookup itself failed. Kept apart from `.taken`, which this used to be
    /// folded into: a network blip is not a claimed username, and telling the user it is sends
    /// them off to invent a new name they never needed.
    case unchecked

    /// The message shown under the field, or `nil` when there is nothing to say.
    var message: String? {
        switch self {
        case .idle, .checking, .valid:
            return nil
        case .tooShort:
            return "Usernames need at least 3 characters."
        case .taken:
            return "That username is already taken."
        case .invalid:
            return "Use only letters, numbers, full stops and underscores."
        case .unchecked:
            return "We couldn't check that username. Check your connection."
        }
    }
}
