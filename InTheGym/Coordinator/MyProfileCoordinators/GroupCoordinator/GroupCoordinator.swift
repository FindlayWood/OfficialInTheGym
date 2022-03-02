//
//  GroupCoordinator.swift
//  InTheGym
//
//  Created by Findlay Wood on 06/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

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
    
    func addNewGroup(with delegate: MyGroupsProtocol) {
        let vc = CreateNewGroupViewController()
        vc.coordinator = self
        vc.delegate = delegate
        vc.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(vc, animated: true)
    }
    
    func addPlayersToNewGroup(_ delegate: SelectPlayersProtocol, selectedPlayers: [Users]) {
        let vc = GroupAddPlayersViewController()
        vc.modalTransitionStyle = .coverVertical
        vc.delegate = delegate
        vc.alreadySelectedPlayers = selectedPlayers
        navigationController.present(vc, animated: true, completion: nil)
    }
    
//    func addNewGroup(with delegate: MyGroupsProtocol) {
//        let vc = AddNewGroupViewController.instantiate()
//        vc.delegate = delegate
//        navigationController.pushViewController(vc, animated: true)
//    }
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
