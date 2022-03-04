//
//  AdminPlayersViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 04/03/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import Combine

class AdminPlayersViewModel {
    
    // MARK: - Publishers
    var playersPublisher = CurrentValueSubject<[Users],Never>([])
    var errorLoadingPublisher = PassthroughSubject<Error,Never>()
    
    @Published var isLoading: Bool = false
    
    // MARK: - Properties
    var apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared
    
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
    }
    
    // MARK: - Actions
    
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
    
    func loadPlayers(from keys: [String]) {
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
}
