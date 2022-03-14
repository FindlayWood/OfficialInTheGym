//
//  RequestsViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 18/03/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import Combine

class RequestsViewModel {
    
    // MARK: - Publishers
    var requestsPublisher = CurrentValueSubject<[RequestCellModel],Never>([])
    
    var errorPublisher = PassthroughSubject<Error,Never>()
    
    // MARK: - Properties
    var navigationTitle = "My Requests"
    
    var apiService: FirebaseDatabaseManagerService
    
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
    }
 
    
    // MARK: - Fetching functions
    func fetchRequests() {
        let searchModel = RequestSearchModel(id: UserDefaults.currentUser.uid)
        apiService.fetchKeys(from: searchModel) { [weak self] result in
            switch result {
            case .success(let keys):
                self?.loadRequests(from: keys)
            case .failure(let error):
                self?.errorPublisher.send(error)
            }
        }
        
//        let keys = ["LS8kpGDQmkScBHbfN9aBaz3lDzP2", "2amSPGcjkWazWWGjksruRbvl6cF3", "VWhta8sZ8EN0JUfdoyKVCgznijD3", "h5EjeDAeVbN3KgwVBe4dIcSYHqt2", "yULnDYa8vFOznhXh9beX7bLLbn53", "fZKSEr4e6yWdYqt0P6BXbnyg1pf2", "tmNRVFlUNVQTBuSEV3j2eb580fd2", "EIPmHvETuwZbpBFIW4RWu3lYBSZ2", "xANGtU2nEHhLfPKemXuJnmfQnMq1"]
//        let models = keys.map { UserSearchModel(uid: $0)}
//        apiService.fetchRange(from: models, returning: Users.self) { [weak self] result in
//            switch result {
//            case .success(let users):
//                let cellModels = users.map { RequestCellModel(user: $0) }
//                self?.requestsPublisher.send(cellModels)
//            case .failure(_):
//                break
//            }
//        }
    }
    
    private func loadRequests(from keys: [String]) {
        let models = keys.map { UserSearchModel(uid: $0)}
        apiService.fetchRange(from: models, returning: Users.self) { [weak self] result in
            switch result {
            case .success(let users):
                let cellModels = users.map { RequestCellModel(user: $0)}
                self?.requestsPublisher.send(cellModels)
            case .failure(let error):
                self?.errorPublisher.send(error)
            }
        }
    }

    
    // MARK: - Actions

    func removeRequest(_ model: RequestCellModel) {
        
    }

}
