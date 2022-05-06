//
//  GroupCoordinator.swift
//  InTheGym
//
//  Created by Findlay Wood on 06/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit
import Combine

class GroupCoordinator: NSObject, Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        navigationController.delegate = self
        let vc = MyGroupsViewController()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
}
//MARK: Flow Methods
extension GroupCoordinator {
    
    func goToGroupHome(_ group: GroupModel) {
        let child = GroupHomeCoordinator(navigationController: navigationController, group: group)
        childCoordinators.append(child)
        child.start()
    }
    
    func addNewGroup(listener: PassthroughSubject<GroupModel,Never>) {
        let vc = CreateNewGroupViewController()
        vc.hidesBottomBarWhenPushed = true
        vc.coordinator = self
        vc.viewModel.createdNewGroup = listener
        navigationController.pushViewController(vc, animated: true)
    }
    func addUsers(_ currentUsers: [Users], listener: CurrentValueSubject<[Users],Never>) {
        let vc = UserSelectionViewController()
        vc.viewModel.currentlySelectedUsers = Set(currentUsers)
        vc.viewModel.selectedUsers = listener
        navigationController.present(vc, animated: true)
    }
    
}
//MARK: - Navigation Delegate Method
extension GroupCoordinator: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        guard let fromViewController = navigationController.transitionCoordinator?.viewController(forKey: .from) else {
            return
        }
        
        if navigationController.viewControllers.contains(fromViewController){
            return
        }
    }
}
