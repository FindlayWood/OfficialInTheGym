//
//  DiscoverCoordinator.swift
//  InTheGym
//
//  Created by Findlay Wood on 05/05/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

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
        let child = WorkoutDiscoveryCoordinator(navigationController: navigationController, savedWorkoutModel: model)
        childCoordinators.append(child)
        child.start()
    }
    
    func exerciseSelected(_ model: DiscoverExerciseModel) {
        let child = ExerciseDiscoveryCoordinator(navigationController: navigationController, exercise: model)
        childCoordinators.append(child)
        child.start()
    }
    
    func clipSelected(_ model: ClipModel, fromViewControllerDelegate: CustomAnimatingClipFromVC) {
        let keyClipModel = KeyClipModel(clipKey: model.id, storageURL: model.storageURL)
        let child = ClipProfileCustomCoordinator(navigationController: navigationController, clipModel: keyClipModel, fromViewControllerDelegate: fromViewControllerDelegate)
        childCoordinators.append(child)
        child.start()
    }
    
    func moreWorkoutsSelected() {
        let vc = DiscoverMoreWorkoutsViewController()
        vc.coordinator = self
        vc.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(vc, animated: true)
    }
    func moreClipsSelected() {
        let vc = DiscoverMoreClipsViewController()
        vc.coordinator = self
        vc.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(vc, animated: true)
    }
    func moreExercisesSelected(_ emptyExercise: ExerciseModel) {
        let vc = ExerciseSelectionViewController()
        vc.coordinator = self
        vc.viewModel.exercise = emptyExercise
        navigationController.pushViewController(vc, animated: true)
    }
    func moreTagsSelected(text: String?) {
        let child = SearchTagCoordinator(navigationController: navigationController, searchText: text)
        childCoordinators.append(child)
        child.start()
    }
    func search() {
        let vc = SearchViewController()
        vc.coordinator = self
        vc.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(vc, animated: true)
    }
}
extension DiscoverCoordinator: UserSearchFlow {
    func userSelected(_ user: Users) {
        let child = UserProfileCoordinator(navigationController: navigationController, user: user)
        childCoordinators.append(child)
        child.start()
    }
}
extension DiscoverCoordinator: ExerciseSelectionFlow {
    func exerciseSelected(_ exercise: ExerciseModel) {
        let discoverModel = DiscoverExerciseModel(exerciseName: exercise.exercise)
        exerciseSelected(discoverModel)
    }
    func otherSelected(_ exercise: ExerciseModel) {
        let vc = OtherExerciseViewController()
        vc.viewModel.exerciseModel = exercise
        vc.coordinator = self
        navigationController.present(vc, animated: true)
    }
    func infoSelected(_ discoverModel: DiscoverExerciseModel) {
        let child = ExerciseDiscoveryCoordinator(navigationController: navigationController, exercise: discoverModel)
        childCoordinators.append(child)
        child.start()
    }
    func addCircuit() {
        
    }
    
    func addAmrap() {
        
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
    }
}
