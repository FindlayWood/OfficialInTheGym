//
//  GroupMembersViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 03/03/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import Combine

class GroupMembersViewModel {
    
    // MARK: - Publishers
    var membersPublisher = PassthroughSubject<[Users],Never>()
    var errorFetchingMembers = PassthroughSubject<Error,Never>()
    
    // MARK: - Properties
    var apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared
    
    var group: GroupModel!
    
    var navigationTitle = "Group Members"
    
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
    }
    
    // MARK: - Actions
    
    // MARK: - Functions
    func fetchMembers() {
        let membersModel = GroupMembersModel(id: group.uid)
        apiService.fetchKeys(from: membersModel) { [weak self] result in
            switch result {
            case .success(let keys):
                self?.loadMembers(from: keys)
            case .failure(let error):
                self?.errorFetchingMembers.send(error)
            }
        }
    }
    
    func loadMembers(from keys: [String]) {
        let keyModels = keys.map { UserSearchModel(uid: $0) }
        apiService.fetchRange(from: keyModels, returning: Users.self) { [weak self] result in
            switch result {
            case .success(let members):
                self?.membersPublisher.send(members)
            case .failure(let error):
                self?.errorFetchingMembers.send(error)
            }
        }
    }
}
