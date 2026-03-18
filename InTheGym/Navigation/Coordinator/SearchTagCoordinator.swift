//
//  SearchTagCoordinator.swift
//  InTheGym
//
//  Created by Findlay Wood on 26/05/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

class SearchTagCoordinator: NSObject, Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    var searchText: String?
    var subscriptionManager: PurchaseManager
    
    init(navigationController: UINavigationController, searchText: String? = nil, subscriptionManager: PurchaseManager) {
        self.navigationController = navigationController
        self.searchText = searchText
        self.subscriptionManager = subscriptionManager
    }
    
    func start() {
        let vc = DiscoverMoreTagsViewController()
        vc.viewModel.searchText = searchText ?? ""
        vc.display.searchField.text = searchText
        vc.hidesBottomBarWhenPushed = true
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
}
// MARK: - Actions
extension SearchTagCoordinator {
    func exerciseSelected(_ model: DiscoverExerciseModel) {
        let child = ExerciseDiscoveryCoordinator(navigationController: navigationController, exercise: model, subscriptionManager: subscriptionManager)
        childCoordinators.append(child)
        child.start()
    }
}
