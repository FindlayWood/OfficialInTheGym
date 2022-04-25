//
//  AssigningSelectionViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 18/04/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import Combine

class AssigningSelectedionViewModel {
    
    // MARK: - Publishers
    @Published var isLoading: Bool = false
    @Published var isUploadingToGroup: Bool = false
    var playersPublisher = PassthroughSubject<[Users],Never>()
    var errorLoadingPublisher = PassthroughSubject<Error,Never>()
    var addedWorkoutPublisher = PassthroughSubject<Bool,Never>()
    var addedGroupWorkoutPublisher = PassthroughSubject<Bool,Never>()
    var membersPublisher = PassthroughSubject<[Users],Never>()
    
    // MARK: - Properties
    var apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared
    
    var savedWorkoutModel: SavedWorkoutModel!
    
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
    }
    
    // MARK: - Actions
    func selectedPlayer(_ player: Users) {
        let workoutModel = WorkoutModel(savedModel: savedWorkoutModel, assignTo: player.uid)
        apiService.uploadTimeOrderedModel(model: workoutModel) { [weak self] result in
            switch result {
            case .success(_):
                self?.addedWorkoutPublisher.send(true)
            case .failure(_):
                self?.addedWorkoutPublisher.send(false)
            }
        }
    }
    func selectedGroup(_ group: GroupModel) {
        membersPublisher
            .sink { [weak self] members in
                self?.isUploadingToGroup = true
                members.forEach { member in
                    self?.selectedPlayer(member)
                }
                self?.isUploadingToGroup = false
                self?.addedGroupWorkoutPublisher.send(true)
            }.store(in: &subscriptions)
        
        fetchMembers(for: group)
    }
    
    // MARK: - Functions
    func fetchPlayers() {
        isLoading = true
        let keyModel = CoachPlayersKeyModel()
        apiService.fetchKeys(from: keyModel) { [weak self] result in
            switch result {
            case .success(let keys):
                self?.loadPlayers(from: keys)
            case .failure(let error):
                self?.errorLoadingPublisher.send(error)
                self?.isLoading = false
            }
        }
    }
    
    private func loadPlayers(from keys: [String]) {
        let models = keys.map { UserSearchModel(uid: $0) }
        apiService.fetchRange(from: models, returning: Users.self) { [weak self] result in
            switch result {
            case .success(let players):
                self?.playersPublisher.send(players)
                self?.isLoading = false
            case .failure(let error):
                self?.errorLoadingPublisher.send(error)
                self?.isLoading = false
            }
        }
    }
    
    // MARK: - Functions
    private func fetchMembers(for group: GroupModel) {
        let membersModel = GroupMembersModel(id: group.uid)
        apiService.fetchKeys(from: membersModel) { [weak self] result in
            switch result {
            case .success(let keys):
                self?.loadMembers(from: keys)
            case .failure(let error):
                self?.errorLoadingPublisher.send(error)
            }
        }
    }
    
    private func loadMembers(from keys: [String]) {
        let keyModels = keys.map { UserSearchModel(uid: $0) }
        apiService.fetchRange(from: keyModels, returning: Users.self) { [weak self] result in
            switch result {
            case .success(let members):
                self?.membersPublisher.send(members)
            case .failure(let error):
                self?.errorLoadingPublisher.send(error)
            }
        }
    }

}
