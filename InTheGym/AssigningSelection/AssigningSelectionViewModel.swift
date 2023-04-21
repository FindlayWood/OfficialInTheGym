//
//  AssigningSelectionViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 18/04/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import Combine

class AssigningSelectedionViewModel: ObservableObject {
    
    // MARK: - Publishers
    @Published var isLoading: Bool = false
    @Published var isUploading: Bool = false
    @Published var users: [Users] = []
    @Published var selectedUsers: [Users] = []
    
    var uploadedPublisher = PassthroughSubject<Void,Never>()
    var playersPublisher = PassthroughSubject<[Users],Never>()
    var errorLoadingPublisher = PassthroughSubject<Error,Never>()
    var addedWorkoutPublisher = PassthroughSubject<Bool,Never>()
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
    func assignAction() {
        isUploading = true
        for player in selectedUsers {
            selectedPlayer(player)
        }
        isUploading = false
        uploadedPublisher.send(())
    }
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
                self?.users = players
                self?.isLoading = false
            case .failure(let error):
                self?.errorLoadingPublisher.send(error)
                self?.isLoading = false
            }
        }
    }
}
