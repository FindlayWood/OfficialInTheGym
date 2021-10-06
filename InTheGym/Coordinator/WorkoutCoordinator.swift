//
//  WorkoutCoordinator.swift
//  InTheGym
//
//  Created by Findlay Wood on 06/05/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

protocol WorkoutCoordinatorFlow: WorkoutDisplayCoordinator {
    func showUser(with user: Users)
    func showWorkoutStats(with savedWorkoutID: String)
    func showCircuit()
    func showAMRAP(with model: AMRAP, at position: Int, on workout: workout)
    func showEMOM(_ emom: EMOM, _ workout: workout)
    func displayNote(with note: String?, on workout: WorkoutDelegate, at index: Int)
    
}

protocol WorkoutDisplayCoordinator: Coordinator {
    func showCompletedPage()
}

/// Child Coordinator to handle the flow when a workout is displayed
class WorkoutCoordinator: NSObject, Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    
    var workout: WorkoutDelegate
    
    init(navigationController: UINavigationController, workout: WorkoutDelegate) {
        self.navigationController = navigationController
        self.workout = workout
    }
    
    func start() {
        let vc = DisplayWorkoutViewController.instantiate()
        vc.coordinator = self
        DisplayWorkoutViewController.selectedWorkout = workout
        vc.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(vc, animated: true)
    }
    
    func childDidFinish(_ child: Coordinator?) {
        for (index, coordinator) in childCoordinators.enumerated() {
            if coordinator === child {
                childCoordinators.remove(at: index)
                break
            }
        }
    }
}


//MARK: - Flow Methods
extension WorkoutCoordinator: WorkoutCoordinatorFlow {
    func showCircuit() {
        let vc = DisplayCircuitViewController.instantiate()
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showAMRAP(with model: AMRAP, at position: Int, on workout: workout) {
        if #available(iOS 13.0, *) {
            let vc = DisplayAMRAPViewController()
            vc.amrap = model
            vc.amrapPosition = position
            vc.workout = workout
            navigationController.pushViewController(vc, animated: true)
        }
    }
    
    func displayNote(with note: String?, on workout: WorkoutDelegate, at index: Int) {
        let vc = DisplayNoteViewController()
        vc.currentNote = note
        vc.currentWorkout = workout
        vc.noteIndex = index
        navigationController.present(vc, animated: true, completion: nil)
    }
    
    func showCompletedPage() {
        let vc = WorkoutCompletedViewController.instantiate()
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showUser(with user: Users) {
        let child = UserProfileCoordinator(navigationController: navigationController, user: user)
        childCoordinators.append(child)
        child.start()
    }
    
    func showWorkoutStats(with savedWorkoutID: String) {
        let vc = DisplayWorkoutStatsViewController()
        vc.savedWorkoutID = savedWorkoutID
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showEMOM(_ emom: EMOM, _ workout: workout) {
        let vc = DisplayEMOMViewController()
        vc.emom = emom
        vc.workout = workout
        navigationController.pushViewController(vc, animated: true)
    }
}


//MARK: - Navigation Delegate Method
extension WorkoutCoordinator: UINavigationControllerDelegate {
    
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
