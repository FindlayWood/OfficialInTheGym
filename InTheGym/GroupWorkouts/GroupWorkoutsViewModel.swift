//
//  GroupWorkoutsViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 18/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation

class GroupWorkoutsViewModel {
    
    // MARK: - Callbacks
    var reloadTableViewCallback: (() -> ())?
    var updateLoadingStatusCallback: (() -> ())?
    
    // MARK: - Properties
    var groupWorkouts: [GroupWorkoutModel] = [] {
        didSet {
            reloadTableViewCallback?()
            groupWorkoutsLoadedSuccessfully = true
        }
    }
    var numberOfWorkouts: Int {
        return groupWorkouts.count
    }
    var isLoading: Bool = false {
        didSet {
            updateLoadingStatusCallback?()
        }
    }
    var groupWorkoutsLoadedSuccessfully: Bool = false
    var apiService: FirebaseAPIGroupServiceProtocol
    // MARK: - Initializer
    init(apiService: FirebaseAPIGroupServiceProtocol) {
        self.apiService = apiService
    }
    //MARK: - Fetching Functions
    func fetchWorkouts(from groupID: String) {
        isLoading = true
        apiService.fetchGroupWorkouts(from: groupID) { [weak self] result in
            guard let self = self else {return}
            switch result {
            case .success(let workouts):
                self.groupWorkouts = workouts
                self.isLoading = false
            case .failure(let error):
                print(error.localizedDescription)
                self.isLoading = false
            }
        }
    }
    
    // MARK: - Returning Functions
    func getData(at indexPath: IndexPath) -> GroupWorkoutModel {
        return groupWorkouts[indexPath.section]
    }
}
