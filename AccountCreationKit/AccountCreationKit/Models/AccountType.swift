//
//  AccountType.swift
//  AccountCreationKit
//
//  Created by Findlay Wood on 09/08/2026.
//

import Foundation

/// Kept because `Users.accountType` is non-optional and every document already written carries one.
/// **The creation flow no longer asks** — everything created now is `.individual`, and coaching is
/// something a user takes on later rather than a kind of account they declare at signup.
public enum AccountType: String, CaseIterable, Identifiable, Codable {

    case individual
    case athlete
    case coach

    public var id: String { title }

    public var title: String {
        switch self {
        case .individual:
            return "Individual"
        case .athlete:
            return "Athlete"
        case .coach:
            return "Coach"
        }
    }
}
