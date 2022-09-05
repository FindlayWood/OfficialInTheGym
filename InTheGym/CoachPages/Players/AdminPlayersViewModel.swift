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
        let fakeKeys = ["LS8kpGDQmkScBHbfN9aBaz3lDzP2", "2amSPGcjkWazWWGjksruRbvl6cF3", "VWhta8sZ8EN0JUfdoyKVCgznijD3", "h5EjeDAeVbN3KgwVBe4dIcSYHqt2", "yULnDYa8vFOznhXh9beX7bLLbn53", "fZKSEr4e6yWdYqt0P6BXbnyg1pf2", "tmNRVFlUNVQTBuSEV3j2eb580fd2", "EIPmHvETuwZbpBFIW4RWu3lYBSZ2", "xANGtU2nEHhLfPKemXuJnmfQnMq1"]
        let models = fakeKeys.map { UserSearchModel(uid: $0) }
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
