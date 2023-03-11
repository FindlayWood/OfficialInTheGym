//
//  TaggedUsersCoordinator.swift
//  InTheGym
//
//  Created by Findlay-Personal on 11/03/2023.
//  Copyright © 2023 FindlayWood. All rights reserved.
//

import UIKit

class TaggedUsersCoordinator: Coordinator {
    // MARK: - Properties
    var childCoordinators: [Coordinator] = [Coordinator]()
    var navigationController: UINavigationController
    var modalNavigationController: UINavigationController?
    var ids: [String]
    // MARK: - Initializer
    init(navigationController: UINavigationController, ids: [String]) {
        self.navigationController = navigationController
        self.ids = ids
    }
    // MARK: - Start
    func start() {
        let vc = TaggedUsersViewController()
        vc.coordinator = self
        vc.viewModel.ids = ids
        modalNavigationController = UINavigationController(rootViewController: vc)
        vc.viewModel.ids = ids
        guard let modalNavigationController else { return }
        modalNavigationController.setNavigationBarHidden(true, animated: false)
        modalNavigationController.modalPresentationStyle = .pageSheet
        if let sheet = modalNavigationController.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
        }
        navigationController.present(modalNavigationController, animated: true)
    }
}

// MARK: - Flow
extension TaggedUsersCoordinator {
    func showUser(_ user: Users) {
        guard let modalNavigationController else { return }
        modalNavigationController.dismiss(animated: true)
        let child = UserProfileCoordinator(navigationController: navigationController, user: user)
        childCoordinators.append(child)
        child.start()
    }
}
