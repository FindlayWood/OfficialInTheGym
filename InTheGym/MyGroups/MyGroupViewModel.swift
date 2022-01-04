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
    var groups = CurrentValueSubject<[groupModel], Never>([])
    var errorFetchingGroups = PassthroughSubject<Error, Never>()
    
    var isLoading: Bool = false {
        didSet{
            updateLoadingStatusClosure?()
        }
    }
    
    private var myGroups: [groupModel] = [] {
        didSet{
            myGroupsLoaded?()
        }
    }
    
    var numberOfGroups : Int {
        return myGroups.count
    }
    
    var apiService: FirebaseDatabaseManagerService
    
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
    }
    
    
    func fetchReferences() {
        FirebaseDatabaseManager.shared.fetchKeys(from: GroupKeysModel.self) { [weak self] result in
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
        FirebaseDatabaseManager.shared.fetchRange(from: groupModels, returning: groupModel.self) { [weak self] result in
            guard let self = self else {return}
            switch result {
            case .success(let myGroups):
                self.groups.send(myGroups)
                self.myGroups = myGroups
            case .failure(let error):
                self.errorFetchingGroups.send(error)
            }
        }
    }
    
    // MARK: - Retreive functions
    func getGroup(at indexPath: IndexPath) -> groupModel {
        return myGroups[indexPath.row]
    }
}
