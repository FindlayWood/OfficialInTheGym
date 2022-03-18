//
//  DescriptionsCellViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 18/03/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import Combine

class DescriptionsCellViewModel {
    
    // MARK: - Publishers
    var votedPublishers = PassthroughSubject<Bool,Never>()
    
    // MARK: - Properties
    var descriptionModel: DescriptionModel!
    
    var apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared
    
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
    }
    
    // MARK: - Actions
    
    // MARK: - Functions
    func vote() {
        let points = descriptionModel.votePoints()
        apiService.multiLocationUpload(data: points) { [weak self] result in
            guard let self = self else {return}
            switch result {
            case .success(()):
                VoteCache.shared.upload(descriptionID: self.descriptionModel.id)
            case .failure(_):
                break
            }
        }
    }
    
    func checkVote() {
        let searchModel = VoteSearchModel(descriptionID: descriptionModel.id, userID: UserDefaults.currentUser.uid)
        VoteCache.shared.load(from: searchModel) { [weak self] result in
            switch result {
            case .success(let voted):
                self?.votedPublishers.send(voted)
            case .failure(_):
                break
            }
        }
    }
}
