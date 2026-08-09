//
//  AccountCreator.swift
//  AccountCreationKit
//
//  Created by Findlay Wood on 09/08/2026.
//

import Foundation

public protocol AccountCreator {
    func createAccount(_ account: CreateAccountModel) async throws
}
