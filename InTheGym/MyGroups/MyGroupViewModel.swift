//
//  MyGroupViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 07/04/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import Firebase
//import CodableFirebase
import Combine

class MyGroupViewModel:NSObject {
    
    // MARK: - Publishers
    var groups = CurrentValueSubject<[GroupModel], Never>([])
    var newGroupCreated = PassthroughSubject<GroupModel,Never>()
    
    var errorFetchingGroups = PassthroughSubject<Error, Never>()
    
    // MARK: - Properties
    var navigationTitle = "My Groups"
    
    var apiService: FirebaseDatabaseManagerService
    
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
    }
    
    // MARK: - Fetch Functions
    func fetchReferences() {
        let referencesModel = GroupReferencesModel(id: UserDefaults.currentUser.uid)
        apiService.fetchKeys(from: referencesModel) { [weak self] result in
            guard let self = self else {return}
            switch result {
            case .success(let keys):
                self.loadGroups(from: keys)
            case .failure(let error):
                self.errorFetchingGroups.send(error)
            }
        }
    }
    
    func loadGroups(from groupIDs: [String]) {
        let groupModels = groupIDs.map { GroupKeysModel(id: $0) }
        apiService.fetchRange(from: groupModels, returning: GroupModel.self) { [weak self] result in
            guard let self = self else {return}
            switch result {
            case .success(let myGroups):
                self.groups.send(myGroups)
            case .failure(let error):
                self.errorFetchingGroups.send(error)
            }
        }
    }
}
