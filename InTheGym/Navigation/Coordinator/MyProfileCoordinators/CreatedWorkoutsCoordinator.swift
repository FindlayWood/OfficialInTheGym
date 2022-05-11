//
//  CreatedWorkoutsCoordinator.swift
//  InTheGym
//
//  Created by Findlay Wood on 06/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class CreatedWorkoutsCoordinator: NSObject, Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    func start() {
        navigationController.delegate = self
        let vc = CreatedWorkoutsViewController.instantiate()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
}
//MARK: Flow Methods
extension CreatedWorkoutsCoordinator {

}

//MARK: - Navigation Delegate Method
extension CreatedWorkoutsCoordinator: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        guard let fromViewController = navigationController.transitionCoordinator?.viewController(forKey: .from) else {
            return
        }
        
        if navigationController.viewControllers.contains(fromViewController){
            return
        }
    }
}
