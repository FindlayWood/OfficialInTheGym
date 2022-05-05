//
//  UserSelectionViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 05/05/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import Combine

class UserSelectionViewModel {
    
    // MARK: - Publishers
    var selectedUsers = PassthroughSubject<[Users],Never>()
    
    // - All Users
    @Published var allUsers: [UserSelectionCellModel]!
    
    // MARK: - Properties
    
    // - Currently Selected Users
    var currentlySelectedUsers = Set<Users>()
    
    var apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared
    
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
    }
    
    // MARK: - Actions
    func addUser(_ user: Users) {
        currentlySelectedUsers.insert(user)
    }
    func removeUser(_ user: Users) {
        currentlySelectedUsers.remove(user)
    }
    func done() {
        selectedUsers.send(Array(currentlySelectedUsers))
    }
    
    // MARK: - Functions
    func loadUsers() {
        let keys = ["LS8kpGDQmkScBHbfN9aBaz3lDzP2", "2amSPGcjkWazWWGjksruRbvl6cF3", "VWhta8sZ8EN0JUfdoyKVCgznijD3", "h5EjeDAeVbN3KgwVBe4dIcSYHqt2", "yULnDYa8vFOznhXh9beX7bLLbn53", "fZKSEr4e6yWdYqt0P6BXbnyg1pf2", "tmNRVFlUNVQTBuSEV3j2eb580fd2", "EIPmHvETuwZbpBFIW4RWu3lYBSZ2", "xANGtU2nEHhLfPKemXuJnmfQnMq1"]
        let models = keys.map { UserSearchModel(uid: $0)}
        apiService.fetchRange(from: models, returning: Users.self) { [weak self] result in
            guard let self = self else {return}
            switch result {
            case .success(let users):
                let cellModels = users.map { UserSelectionCellModel(isSelected: self.currentlySelectedUsers.contains($0), user: $0)}
                self.allUsers = cellModels
            case .failure(_):
                break
            }
        }
    }
}
