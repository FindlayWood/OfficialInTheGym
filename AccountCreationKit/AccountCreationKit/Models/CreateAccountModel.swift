//
//  CreateAccountModel.swift
//  AccountCreationKit
//
//  Created by Findlay Wood on 09/08/2026.
//

import Foundation

/// The account the user has assembled across the creation steps.
///
/// How this is written — the callable function's name, the shape of its payload — belongs to the
/// composition root, not here. See `AccountCreator`.
public struct CreateAccountModel: Codable {
    public var uid: String
    public var email: String
    public var username: String
    public var displayName: String
    public var bio: String
    public var accountType: AccountType
    public var createdDate: Date
    public var verifiedAccount: Bool
    public var eliteAccount: Bool
    public var isPrivate: Bool

    public init(
        uid: String,
        email: String,
        username: String,
        displayName: String,
        bio: String,
        accountType: AccountType,
        createdDate: Date = .now,
        verifiedAccount: Bool = false,
        eliteAccount: Bool = false,
        isPrivate: Bool = false
    ) {
        self.uid = uid
        self.email = email
        self.username = username
        self.displayName = displayName
        self.bio = bio
        self.accountType = accountType
        self.createdDate = createdDate
        self.verifiedAccount = verifiedAccount
        self.eliteAccount = eliteAccount
        self.isPrivate = isPrivate
    }
}
