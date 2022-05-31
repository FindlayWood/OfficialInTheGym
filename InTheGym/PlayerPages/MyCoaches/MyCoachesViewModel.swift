//
//  MyCoachesViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 30/05/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import Combine

class MyCoachesViewModel {
    // MARK: - Publishers
    @Published var isLoading: Bool = false
    @Published var coachModels: [Users] = []
    @Published var error: Error?
    
    // MARK: - Properties
    var apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared
    
    var navigationTitle: String {
        "My Coaches"
    }
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
    }
    
    // MARK: - Actions
    
    // MARK: - Functions
    func fetchCoachKeys() {
        isLoading = true
        let searchModel = MyCoachesSearchModel(userID: UserDefaults.currentUser.uid)
        apiService.fetchKeys(from: searchModel) { [weak self] result in
            switch result {
            case .success(let keys):
                self?.loadCoaches(from: keys)
            case .failure(let error):
                self?.error = error
                self?.isLoading = false
            }
        }
    }
    private func loadCoaches(from keys: [String]) {
        let models = keys.map { UserSearchModel(uid: $0)}
        apiService.fetchRange(from: models, returning: Users.self) { [weak self] result in
            switch result {
            case .success(let coachModels):
                self?.coachModels = coachModels
                self?.isLoading = false
            case .failure(let error):
                self?.error = error
                self?.isLoading = false
            }
        }
    }
}
