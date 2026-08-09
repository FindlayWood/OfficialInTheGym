//
//  AccountCreationComposition.swift
//  InTheGym
//
//  Created by Findlay-Personal on 12/04/2023.
//  Copyright © 2023 FindlayWood. All rights reserved.
//

import AccountCreationKit
import UIKit

class AccountCreationComposition {

    func composeCombination(
        _ navigationController: UINavigationController,
        email: String,
        uid: String,
        completedCallback: @escaping () -> Void,
        signOutCallback: @escaping () -> Void
    ) {

        let router = AccountCreationKitRouter(
            navigationController: navigationController,
            user: AccountCreationUserModel(email: email, uid: uid),
            usernameChecker: FirestoreUsernameAvailabilityChecker(),
            usernameReserver: FirestoreUsernameReserver(),
            accountCreator: FunctionsAccountCreator(),
            profileImageUploader: StorageProfileImageUploader(),
            signOutService: FirebaseAccountCreationSignOut(),
            onAccountCreated: completedCallback,
            onSignedOut: signOutCallback
        )

        router.start()
    }
}

protocol AccountCreationComposer {
    func startAccountCreation(email: String, uid: String)
}

struct AccountCreationComposerAdapter: AccountCreationComposer {
    var navigationController: UINavigationController
    var completion: () -> Void
    var signedOut: () -> Void

    func startAccountCreation(email: String, uid: String) {
        AccountCreationComposition().composeCombination(
            navigationController,
            email: email,
            uid: uid,
            completedCallback: completion,
            signOutCallback: signedOut
        )
    }
}
