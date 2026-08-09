//
//  AccountCreationKitRouter.swift
//  AccountCreationKit
//
//  Created by Findlay Wood on 09/08/2026.
//

import UIKit

public final class AccountCreationKitRouter {

    // MARK: - Navigation

    let navigationController: UINavigationController

    // MARK: - Dependencies

    let user: AccountCreationUserModel
    let usernameChecker: UsernameAvailabilityChecker
    let usernameReserver: UsernameReserver
    let accountCreator: AccountCreator
    let profileImageUploader: ProfileImageUploader
    let signOutService: AccountCreationSignOutService

    // MARK: - Callbacks

    let onAccountCreated: () -> Void
    let onSignedOut: () -> Void

    // MARK: - Init

    public init(
        navigationController: UINavigationController,
        user: AccountCreationUserModel,
        usernameChecker: UsernameAvailabilityChecker,
        usernameReserver: UsernameReserver,
        accountCreator: AccountCreator,
        profileImageUploader: ProfileImageUploader,
        signOutService: AccountCreationSignOutService,
        onAccountCreated: @escaping () -> Void,
        onSignedOut: @escaping () -> Void
    ) {
        self.navigationController = navigationController
        self.user = user
        self.usernameChecker = usernameChecker
        self.usernameReserver = usernameReserver
        self.accountCreator = accountCreator
        self.profileImageUploader = profileImageUploader
        self.signOutService = signOutService
        self.onAccountCreated = onAccountCreated
        self.onSignedOut = onSignedOut
    }

    // MARK: - Root

    public func start() {
        let rootVC = viewController(for: .home)
        navigationController.setViewControllers([rootVC], animated: true)
    }

    func viewController(for route: AccountCreationRoutes) -> UIViewController {
        switch route {
        case .home:
            let viewModel = AccountCreationHomeViewModel(
                user: user,
                usernameChecker: usernameChecker,
                usernameReserver: usernameReserver,
                accountCreator: accountCreator,
                profileImageUploader: profileImageUploader,
                signOutService: signOutService,
                onAccountCreated: onAccountCreated,
                onSignedOut: onSignedOut
            )
            let vc = AccountCreationBoundaryViewController()
            vc.display = AccountCreationHomeScreen(viewModel: viewModel)
            return vc
        }
    }
}
