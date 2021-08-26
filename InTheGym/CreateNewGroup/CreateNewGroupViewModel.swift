//
//  CreateNewGroupViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 09/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation

class CreateNewGroupViewModel {
    
    // MARK: - Callbacks
    var reloadTableViewClosure: (() -> ())?
    var successfullCreationClosure: (() -> Void)?
    var errorCreationClosure: (() -> Void)?
    
    // MARK: - Properties
    var addedPlayers: [Users] = [] {
        didSet {
            reloadTableViewClosure?()
        }
    }
    
    var numberOfItems: Int {
        return addedPlayers.count
    }
    
    var apiService: FirebaseAPIGroupServiceProtocol
    
    var newGroup = NewGroupModel()
    
    var groupTitle: String {
        return newGroup.title
    }
    var groupPlayers: [Users] {
        return newGroup.players
    }
    var successfullCreation: Bool = false {
        didSet {
            successfullCreationClosure?()
        }
    }
    var error: Bool = false {
        didSet {
            errorCreationClosure?()
        }
    }
    
    // MARK: - Initializer
    init(apiService: FirebaseAPIGroupServiceProtocol) {
        self.apiService = apiService
    }
    
    // MARK: - API Methods
    func createNewGroup() {
        apiService.createGroup(with: newGroup) { [weak self] success in
            guard let self = self else {return}
            if success {
                self.successfullCreation = true
            } else {
                self.error = true
            }
        }
    }
    
    // MARK: - Delegate Methods
    func getData(at indexPath: IndexPath) -> Users {
        return addedPlayers[indexPath.section]
    }
    func addNewPlayers(_ players: [Users]) {
        addedPlayers = players
        newGroup.players = players
    }
    
    // MARK: - Update Model Functions
    func updateGroupTitle(with newTitle: String) {
        newGroup.title = newTitle
    }
}

struct NewGroupModel {
    var title: String = ""
    var description: String = ""
    var players: [Users] = []
}
