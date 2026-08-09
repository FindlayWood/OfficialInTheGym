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
}
