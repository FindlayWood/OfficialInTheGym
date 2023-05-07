//
//  File.swift
//  
//
//  Created by Findlay-Personal on 04/05/2023.
//

import Foundation

protocol WorkoutKitFactory {
    func makeWorkoutHomeViewController() -> WorkoutsHomeViewController
    func makeWorkoutDisplayViewController(for workout: RemoteWorkoutModel) -> WorkoutDisplayViewController
}

protocol NetworkServiceFactory {
    func makeNetworkService() -> NetworkService
}


protocol ViewModelFactory {
    func makeWorkoutHomeViewModel() -> WorkoutsHomeViewModel
    func makeWorkoutDisplayViewModel(with workout: RemoteWorkoutModel) -> WorkoutDisplayViewModel
    func makeWorkoutCreationViewModel() -> WorkoutCreationHomeViewModel
}

protocol RemoteModelFactory {
    func makeRemoteWorkoutModel(title: String, isPrivate: Bool, exerciseCount: Int) -> RemoteWorkoutModel
}

import UIKit
class CoordinatorFactory: HomeFactory {
    var workoutManager: WorkoutManager
    var networkService: NetworkService
    var userService: CurrentUserServiceWorkoutKit
    var navigationController: UINavigationController
    
    init(workoutManager: WorkoutManager, networkService: NetworkService, userService: CurrentUserServiceWorkoutKit, navigationController: UINavigationController) {
        self.workoutManager = workoutManager
        self.networkService = networkService
        self.userService = userService
        self.navigationController = navigationController
    }
    
    func makeHomeWorkoutCoordinator() -> WorkoutsHomeFlow {
        let coordinator = WorkoutsHomeCoordinator(factory: self)
        return coordinator
    }
    func makeDiplayWorkoutCoordinator(workout: RemoteWorkoutModel) -> DisplayFlow{
        let coordinator = DisplayCoordinator(factory: self, workout: workout)
        return coordinator
    }
    func makeWorkoutCreationCoordinator() -> CreationFlow {
        return CreationCoordinator(factory: self)
    }
}
extension CoordinatorFactory: ViewModelFactory {
    func makeWorkoutHomeViewModel() -> WorkoutsHomeViewModel {
        return WorkoutsHomeViewModel(workoutManager: workoutManager)
    }
    func makeWorkoutDisplayViewModel(with workout: RemoteWorkoutModel) -> WorkoutDisplayViewModel {
        return WorkoutDisplayViewModel(workoutManager: workoutManager, workoutModel: workout)
    }
    func makeWorkoutCreationViewModel() -> WorkoutCreationHomeViewModel {
        return WorkoutCreationHomeViewModel(workoutManager: workoutManager, factory: self)
    }
}
extension CoordinatorFactory: RemoteModelFactory {
    func makeRemoteWorkoutModel(title: String, isPrivate: Bool, exerciseCount: Int) -> RemoteWorkoutModel {
        return RemoteWorkoutModel(title: title, creatorID: userService.currentUserUID, assignedBy: userService.currentUserUID, assignedTo: userService.currentUserUID, isPrivate: isPrivate, exerciseCount: exerciseCount)
    }
}

protocol HomeFactory {
    var networkService: NetworkService { get }
    var userService: CurrentUserServiceWorkoutKit { get }
    var navigationController: UINavigationController { get }
    func makeHomeWorkoutCoordinator() -> WorkoutsHomeFlow
    func makeDiplayWorkoutCoordinator(workout: RemoteWorkoutModel) -> DisplayFlow
    func makeWorkoutCreationCoordinator() -> CreationFlow
}


class PreviewRemoteModelFactory: RemoteModelFactory {
    func makeRemoteWorkoutModel(title: String, isPrivate: Bool, exerciseCount: Int) -> RemoteWorkoutModel {
        return RemoteWorkoutModel(title: title, creatorID: "", assignedBy: "", assignedTo: "", isPrivate: isPrivate, exerciseCount: exerciseCount)
    }
}
