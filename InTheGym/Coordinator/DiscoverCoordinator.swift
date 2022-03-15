//
//  DiscoverCoordinator.swift
//  InTheGym
//
//  Created by Findlay Wood on 05/05/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

protocol DiscoverFlow {
    func wodSelected(workout: WorkoutDelegate)
    func workoutSelected(workout: WorkoutDelegate)
    func search()
}

class DiscoverCoordinator: NSObject, Coordinator {

    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController){
        self.navigationController = navigationController
        self.navigationController.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController.navigationBar.shadowImage = UIImage()
        self.navigationController.navigationBar.tintColor = .white
    }
    
    func start() {
        navigationController.delegate = self
        let vc = DiscoverPageViewController()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
}


//MARK: - Flow Methods
extension DiscoverCoordinator {
    
    func workoutSelected(_ model: SavedWorkoutModel) {
        let child = SavedWorkoutCoordinator(navigationController: navigationController, savedWorkoutModel: model)
        childCoordinators.append(child)
        child.start()
    }
    
    func exerciseSelected(_ model: DiscoverExerciseModel) {
        let vc = ExerciseDescriptionViewController()
        vc.viewModel.exercise = model
        vc.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(vc, animated: true)
    }
    
    func programSelected(_ model: SavedProgramModel) {
        
    }
    
    func clipSelected(_ model: ClipModel) {
        
    }
    
    
    func search() {
        let vc = SearchForUsersViewController.instantiate()
        navigationController.pushViewController(vc, animated: true)
    }
}

//MARK: - Navigation Delegate Method
extension DiscoverCoordinator: UINavigationControllerDelegate {
    
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
        
//        if let DiscussionViewController = fromViewController as? DiscussionViewViewController {
//            childDidFinish(DiscussionViewController.coordinator)
//        }
        
        if let WorkoutViewController = fromViewController as? DisplayWorkoutViewController {
            childDidFinish(WorkoutViewController.coordinator)
        }
    }
}
