//
//  SavedWorkoutBottomChildViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 07/03/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import UIKit
import Combine

class SavedWorkoutBottomChildViewModel: ObservableObject {
    
    // MARK: - Publishers
    @Published var optionsList: [Options] = [.addWorkout, .workoutDiscovery, .viewCreatorProfile, .saveWorkout]
    @Published var isWorkoutSaved: Bool = false
    @Published var isLoading: Bool = false
    @Published var isShowingSuccess: Bool = false
    
    var optionsPublisher = PassthroughSubject<[Options],Never>()
    
    var optionsRemovePublisher = PassthroughSubject<Options,Never>()
    var workoutDiscoveryPublisher = PassthroughSubject<Void,Never>()
    var savedWorkoutPublisher = PassthroughSubject<Bool,Never>()
    
    var addedWorkoutPublisher = PassthroughSubject<Bool,Never>()
    
    var removedSavedWorkoutPublisher = PassthroughSubject<Bool,Never>()
    
    var showUserPublisher = PassthroughSubject<Users,Never>()
    
    var showWorkoutStatsPublisher = PassthroughSubject<Void,Never>()
    
    var assignPublisher = PassthroughSubject<Void,Never>()
    
    var listListener: SavedWorkoutRemoveListener?
    
    // MARK: - Properties
    var savedWorkoutModel: SavedWorkoutModel!
    
    var frameOrigin: CGPoint!
    
    let screen = UIScreen.main.bounds
    let normalHeight = Constants.screenSize.height * 0.075
    let expandedHeight = Constants.screenSize.height * 0.6
    lazy var normalFrame = CGRect(x: 0, y: screen.height - normalHeight, width: screen.width, height: maxHeight)
    lazy var expandedFrame = CGRect(x: 0, y: screen.height - expandedHeight, width: screen.width, height: maxHeight)
    lazy var originPoint = normalFrame.origin
    lazy var expandedOriginPoint = expandedFrame.origin
    var bottomViewCurrentState: bottomViewState = .normal
    let maxHeight = Constants.screenSize.height * 0.8
    let minHeight = Constants.screenSize.height * 0.05
    
    var options = [Options]()
    
    var apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared
    
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
    }
    
    // MARK: - Actions
    func setOptions(_ isSaved: Bool) {
        if isSaved {
            options = [.workoutDiscovery, .addWorkout, .viewCreatorProfile, .delete]
            optionsList = [.workoutDiscovery, .addWorkout, .viewCreatorProfile]
        } else {
            options = [.workoutDiscovery, .saveWorkout, .addWorkout, .viewCreatorProfile]
            optionsList = [.workoutDiscovery, .saveWorkout, .addWorkout, .viewCreatorProfile]
        }
//        if UserDefaults.currentUser.uid == savedWorkoutModel.creatorID {
//            options.insert(.viewWorkoutStats, at: 2)
//            optionsList.insert(.viewWorkoutStats, at: 2)
//        }
        if UserDefaults.currentUser.admin {
            options.insert(.assign, at: 0)
            optionsList.insert(.assign, at: 0)
        }
        optionsPublisher.send(options)
    }
    
    func optionSelected(_ option: Options) {
        switch option {
        case .delete:
            removeFromSaved()
        case .addWorkout:
            addToWorkouts()
        case .saveWorkout:
            addToSaved()
        case .viewCreatorProfile:
            loadCreator()
        case .viewWorkoutStats:
            showWorkoutStatsPublisher.send(())
        case .assign:
            assignPublisher.send(())
        case .workoutDiscovery:
            workoutDiscoveryPublisher.send(())
        default:
            break
        }
    }
    
    // MARK: - Functions
    func isSaved() {
        let savedSearchModel = SavedWorkoutReferenceModel(id: savedWorkoutModel.id)
        apiService.checkExistence(of: savedSearchModel) { [weak self] result in
            switch result {
            case .success(let exists):
                self?.setOptions(exists)
                self?.isWorkoutSaved = exists
            case .failure(_):
                self?.setOptions(false)
                self?.isWorkoutSaved = false
            }
        }
    }
    
    // MARK: - Add To Saved
    func addToSaved() {
        isLoading = true
        let savedRefModel = SavedWorkoutReferenceModel(id: savedWorkoutModel.id)
        var uploadPoints = [savedRefModel.toMultipUploadPoint()]
        if savedWorkoutModel.creatorID != UserDefaults.currentUser.uid {
            uploadPoints.append(savedWorkoutModel.downloadUploadPoint())
        }
        apiService.multiLocationUpload(data: uploadPoints) { [weak self] result in
            switch result {
            case .success(()):
                self?.setOptions(true)
                self?.isWorkoutSaved = true
                self?.isLoading = false
                self?.isShowingSuccess = true
            case .failure(_):
                self?.savedWorkoutPublisher.send(false)
                self?.isLoading = false
            }
        }
    }
    // MARK: - Add To Workouts
    func addToWorkouts() {
        isLoading = true
        let workoutModel = WorkoutModel(savedModel: savedWorkoutModel, assignTo: UserDefaults.currentUser.uid)
        apiService.uploadTimeOrderedModel(model: workoutModel) { [weak self] result in
            switch result {
            case .success(_):
                self?.addedWorkoutPublisher.send(true)
                self?.isLoading = false
                self?.isShowingSuccess = true
            case .failure(_):
                self?.addedWorkoutPublisher.send(false)
                self?.isLoading = false
            }
        }
    }
    
    // MARK: - Remove From Saved
    func removeFromSaved() {
        isLoading = true
        let savedRefModel = SavedWorkoutReferenceModel(id: savedWorkoutModel.id)
        let uploadPoint = [savedRefModel.removeUploadPoint()]
        apiService.multiLocationUpload(data: uploadPoint) { [weak self] result in
            guard let self = self else {return}
            switch result {
            case .success(()):
                self.removedSavedWorkoutPublisher.send(true)
                self.optionsRemovePublisher.send(.delete)
                self.listListener?.send(self.savedWorkoutModel)
                self.setOptions(false)
                self.isWorkoutSaved = false
                self.isLoading = false
                self.isShowingSuccess = true
            case .failure(_):
                self.removedSavedWorkoutPublisher.send(false)
                self.isLoading = false
            }
        }
    }
    
    // MARK: - Load Creator
    func loadCreator() {
        let userSearchModel = UserSearchModel(uid: savedWorkoutModel.creatorID)
        UsersLoader.shared.load(from: userSearchModel) { [weak self] result in
            guard let user = try? result.get() else {return}
            self?.showUserPublisher.send(user)
        }
    }
}
