//
//  MyGroupViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 07/04/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import Firebase
import CodableFirebase
import Combine

class MyGroupViewModel:NSObject {

    
    // MARK: - Closures
    var updateLoadingStatusClosure:(()->())?
    var myGroupsLoaded:(()->())?
    
    // MARK: - Combine Publishers
    var groups = CurrentValueSubject<[GroupModel], Never>([])
    var errorFetchingGroups = PassthroughSubject<Error, Never>()
    
    var isLoading: Bool = false {
        didSet{
            updateLoadingStatusClosure?()
        }
    }
    
    var apiService: FirebaseDatabaseManagerService
    
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
    }
    
    
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
    
    // MARK: - Retreive functions
    func getGroup(at indexPath: IndexPath) -> GroupModel {
//        return myGroups[indexPath.row]
        let currentGroups = groups.value
        return currentGroups[indexPath.row]
    }
}
