//
//  FunctionsAccountCreator.swift
//  InTheGym
//
//  Created by Findlay Wood on 09/08/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import AccountCreationKit
import Foundation

struct FunctionsAccountCreator: AccountCreator {

    var functionsService: FunctionsManager = FirebaseFunctionsManager()

    func createAccount(_ account: CreateAccountModel) async throws {
        try await functionsService.callable(named: "createAccount", data: payload(for: account))
    }

    /// The `createAccount` callable's contract. `uid` and `email` are not sent — the function reads
    /// them off the authenticated caller.
    private func payload(for account: CreateAccountModel) -> [String: Any] {
        var data = [String: Any]()
        data["username"] = account.username
        data["displayName"] = account.displayName
        data["bio"] = account.bio
        data["accountType"] = account.accountType.rawValue
        data["isPrivate"] = account.isPrivate
        return data
    }
}
