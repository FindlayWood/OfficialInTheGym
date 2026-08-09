//
//  AccountCreationUserModel.swift
//  AccountCreationKit
//
//  Created by Findlay Wood on 09/08/2026.
//

import Foundation

/// The signed-in user the account is being created for.
public struct AccountCreationUserModel {
    public let email: String
    public let uid: String

    public init(email: String, uid: String) {
        self.email = email
        self.uid = uid
    }
}
