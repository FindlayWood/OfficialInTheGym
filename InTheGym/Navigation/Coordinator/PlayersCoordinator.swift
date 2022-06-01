//
//  PlayersCoordinator.swift
//  InTheGym
//
//  Created by Findlay Wood on 05/05/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

protocol PlayersFlow {
    func addNewPlayer(_ currentPlayers: [Users])
    func showPlayerInMoreDetail(player: Users)
}

class PlayersCoordinator: NSObject, Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.navigationController.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController.navigationBar.shadowImage = UIImage()
        self.navigationController.navigationBar.tintColor = .white
    }
    
    func start() {
        let vc = AdminPlayersViewController()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
}


//MARK: - Flow Methods
extension PlayersCoordinator: PlayersFlow {
    func addNewPlayer(_ currentPlayers: [Users]) {
        let child = AddPlayerCoordinator(navigationController: navigationController, currentPlayers: currentPlayers)
        childCoordinators.append(child)
        child.start()
        
//        let vc = AddPlayerViewController()
//        vc.viewModel.currentPlayers = currentPlayers
//        vc.modalTransitionStyle = .coverVertical
//        vc.modalPresentationStyle = .fullScreen
//        navigationController.present(vc, animated: true, completion: nil)
    }
    func showPlayerInMoreDetail(player: Users) {
        let child = PlayerDetailCoordinator(navigationController: navigationController, player: player)
        childCoordinators.append(child)
        child.start()
    }
    func showMyWorkouts() {
        let child = CoachWorkoutsCoordinator(navigationController: navigationController)
        childCoordinators.append(child)
        child.start()
    }
}

//MARK: - Navigation Delegate Method
extension PlayersCoordinator: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        guard let fromViewController = navigationController.transitionCoordinator?.viewController(forKey: .from) else {
            return
        }
        
        if navigationController.viewControllers.contains(fromViewController){
            return
        }
        
        if let PublicViewController = fromViewController as? PublicTimelineViewController {
            childDidFinish(PublicViewController.coordinator)
        }
    }
}
