//
//  EmomCreationCoordinator.swift
//  InTheGym
//
//  Created by Findlay Wood on 11/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class EmomCreationCoordinator: NSObject, Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    var workoutViewModel: WorkoutCreationViewModel
    
    init(navigationController: UINavigationController, workoutViewModel: WorkoutCreationViewModel) {
        self.navigationController = navigationController
        self.workoutViewModel = workoutViewModel
    }
    
    func start() {
        let vc = CreateEMOMViewController()
        vc.newCoordinator = self
        vc.viewModel.workoutViewModel = workoutViewModel
        navigationController.pushViewController(vc, animated: true)
    }
}

extension EmomCreationCoordinator {
    func upload() {
        let viewControllers: [UIViewController] = navigationController.viewControllers as [UIViewController]
        for controller in viewControllers {
            if controller.isKind(of: WorkoutCreationViewController.self) {
                navigationController.popToViewController(controller, animated: true)
                break
            }
        }
    }
    func exercise(viewModel: CreateEMOMViewModel, workoutPosition: Int) {
        let child = EmomExerciseSelectionCoordinator(navigationController: navigationController, emomViewModel: viewModel, workoutPosition: workoutPosition)
        childCoordinators.append(child)
        child.start()
    }
    
    func showTimePicker(with delegate: TimeSelectionParentDelegate, time: Int) {
        let child = TimeSelectionPickerCoordinator(navigationController: navigationController, parent: delegate, currentTime: time)
        childCoordinators.append(child)
        child.start()
    }
}

//MARK: - Navigation Delegate Method
extension EmomCreationCoordinator: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        guard let fromViewController = navigationController.transitionCoordinator?.viewController(forKey: .from) else {
            return
        }
        
        if navigationController.viewControllers.contains(fromViewController){
            return
        }
        
        if let timeViewController = fromViewController as? TimeSelectionViewController {
            childDidFinish(timeViewController.coordinator)
        }
    }
}


