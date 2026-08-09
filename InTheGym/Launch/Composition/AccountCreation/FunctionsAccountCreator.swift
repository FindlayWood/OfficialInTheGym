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
    ///
    /// **The body fields below are not persisted yet.** The function lives outside this repository
    /// and drops keys it does not know about, so height, weight and date of birth will be discarded
    /// until it is updated to write them onto the user document (and `Users` gains optional
    /// properties to read them back).
    ///
    /// Height is centimetres and weight is kilograms, always — the unit keys say how the user
    /// entered them, not what the numbers mean. Date of birth goes over as an ISO-8601 string
    /// because a callable's payload is JSON and a `Date` has no representation in it.
    private func payload(for account: CreateAccountModel) -> [String: Any] {
        var data = [String: Any]()
        data["username"] = account.username
        data["displayName"] = account.displayName
        data["bio"] = account.bio
        data["accountType"] = account.accountType.rawValue
        data["isPrivate"] = account.isPrivate
        data["heightCentimetres"] = account.heightCentimetres
        data["weightKilograms"] = account.weightKilograms
        data["heightUnit"] = account.heightUnit?.rawValue
        data["weightUnit"] = account.weightUnit?.rawValue
        data["dateOfBirth"] = account.dateOfBirth.map { ISO8601DateFormatter().string(from: $0) }
        return data
    }
}
