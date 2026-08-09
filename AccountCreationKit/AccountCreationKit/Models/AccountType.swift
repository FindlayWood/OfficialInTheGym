//
//  AccountType.swift
//  AccountCreationKit
//
//  Created by Findlay Wood on 09/08/2026.
//

import Foundation

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

    public var message: String {
        switch self {
        case .individual:
            return "Select this type if you are looking to use this app as an individual."
        case .athlete:
            return "Select this type if you are an athlete playing sport / part of a team"
        case .coach:
            return "Select this type if you are looking to manage teams, athlete's or clients."
        }
    }
}
