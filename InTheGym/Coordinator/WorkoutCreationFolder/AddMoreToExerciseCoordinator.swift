//
//  AddMoreToExerciseCoordinator.swift
//  InTheGym
//
//  Created by Findlay Wood on 21/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class AddMoreToExerciseCoordinator: NSObject, Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    var newExercise: exercise
    weak var parentCoordinator: CreationDelegate?
    init(navigationController: UINavigationController, _ exercise: exercise) {
        self.navigationController = navigationController
        self.newExercise = exercise
    }
    func start() {
        
        if #available(iOS 13.0, *) {
            let vc = AddMoreToExerciseViewController()
            vc.newExercise = newExercise
            vc.coordinator = self
            navigationController.pushViewController(vc, animated: true)
        } 

    }
}

extension AddMoreToExerciseCoordinator {
    func timeSelected() {
        let vc = AddMoreTimeViewController()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    func distanceSelected() {
        let vc = AddMoreDistanceViewController()
        navigationController.pushViewController(vc, animated: true)
    }
    func restTimeSelected() {
        let vc = AddMoreRestTimeViewController()
        navigationController.pushViewController(vc, animated: true)
    }
    func noteSelected() {
        
    }
    func timeAdded(_ timeInSeconds: Int) {
        if parentCoordinator is RegularWorkoutCoordinator {
            guard let sets = newExercise.sets else {return}
            let timeArray = Array(repeating: timeInSeconds, count: sets)
            newExercise.time = timeArray
            navigationController.popViewController(animated: true)
        } else if parentCoordinator is LiveWorkoutCoordinator {
            newExercise.time?.append(timeInSeconds)
            navigationController.popViewController(animated: true)
        }

    }
    func distanceAdded(_ distance: String) {
        if parentCoordinator is RegularWorkoutCoordinator {
            guard let sets = newExercise.sets else {return}
            let distacneArray = Array(repeating: distance, count: sets)
            newExercise.distance = distacneArray
            navigationController.popViewController(animated: true)
        } else if parentCoordinator is LiveWorkoutCoordinator {
            newExercise.distance?.append(distance)
            navigationController.popViewController(animated: true)
        }
    }
    func restTimeAdded(_ restTimeInSeconds: Int) {
        if parentCoordinator is RegularWorkoutCoordinator {
            guard let sets = newExercise.sets else {return}
            let restTimeArray = Array(repeating: restTimeInSeconds, count: sets)
            newExercise.restTime = restTimeArray
            navigationController.popViewController(animated: true)
        } else if parentCoordinator is LiveWorkoutCoordinator {
            newExercise.restTime?.append(restTimeInSeconds)
            navigationController.popViewController(animated: true)
        }
    }
    func noteAdded(_ noteText: String) {
        newExercise.note = noteText
    }
    func addNewExercise() {
        let object = newExercise.toObject()
        AddWorkoutHomeViewController.exercises.append(object)
        parentCoordinator?.upload()
    }
    
}
