//
//  AccountCreationHomeViewModel+Preview.swift
//  AccountCreationKit
//
//  Created by Findlay Wood on 09/08/2026.
//

import Foundation

extension AccountCreationHomeViewModel {

    /// A view model backed by doubles that do nothing, for SwiftUI previews.
    static var preview: AccountCreationHomeViewModel {
        let doubles = PreviewAccountCreationServices()
        return AccountCreationHomeViewModel(
            user: .init(email: "preview@inthegym.com", uid: "preview-uid"),
            usernameChecker: doubles,
            usernameReserver: doubles,
            accountCreator: doubles,
            profileImageUploader: doubles,
            signOutService: doubles,
            onAccountCreated: {},
            onSignedOut: {}
        )
    }
}

private struct PreviewAccountCreationServices: UsernameAvailabilityChecker,
                                               UsernameReserver,
                                               AccountCreator,
                                               ProfileImageUploader,
                                               AccountCreationSignOutService {
    func isUsernameAvailable(_ username: String) async throws -> Bool { true }
    func reserveUsername(_ username: String, for uid: String) async throws {}
    func createAccount(_ account: CreateAccountModel) async throws {}
    func uploadProfileImage(_ data: Data, for uid: String) async throws {}
    func signOut() async throws {}
}
