//
//  UploadingCoordinator.swift
//  InTheGym
//
//  Created by Findlay Wood on 23/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class UploadingCoordinator: NSObject, Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    var workoutToUpload: UploadableWorkout
    init(navigationController: UINavigationController, workoutToUpload: UploadableWorkout) {
        self.navigationController = navigationController
        self.workoutToUpload = workoutToUpload
    }
    func start() {
        navigationController.delegate = self
        let vc = UploadingWorkoutViewController()
        vc.coordinator = self
        vc.workoutToUpload = workoutToUpload
        navigationController.pushViewController(vc, animated: true)
    }
}

// MARK: - Flow
extension UploadingCoordinator {
    
    func showUser(user: Users) {
        let child = UserProfileCoordinator(navigationController: navigationController, user: user)
        childCoordinators.append(child)
        child.start()
    }
}

//MARK: - Navigation Delegate Method
extension UploadingCoordinator: UINavigationControllerDelegate {
    
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
