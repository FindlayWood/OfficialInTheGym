//
//  GroupAddPlayersViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 09/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation

class GroupAddPlayersViewModel {
    
    // MARK: - Closures
    var reloadTableViewClosure: (() -> ())?
    var updateLoadingStatucClosure: (() -> ())?
    var errorReturnedClosure: ((LoadingUsersError) -> ())?
    
    // MARK: - Properties
    var apiService: FirebaseLoadUsersServiceProtocol!
    
    var players: [Users] = [] {
        didSet {
            reloadTableViewClosure?()
        }
    }
    
    var isLoading: Bool = false {
        didSet {
            updateLoadingStatucClosure?()
        }
    }
    
    var numberOfPlayers: Int {
        return players.count
    }
    
    var error: LoadingUsersError? = nil {
        didSet {
            guard let error = error else {return}
            errorReturnedClosure?(error)
        }
    }
    
    // MARK: - Initializer
    init(apiService: FirebaseLoadUsersServiceProtocol) {
        self.apiService = apiService
    }
    
    // MARK: - Fetching Methods
    func fetchPlayers() {
        isLoading = true
        apiService.loadPlayers { [weak self] result in
            guard let self = self else {return}
            switch result {
            case .success(let returnedPlayers):
                self.players = returnedPlayers
                self.isLoading = false
            case .failure(let returnedError):
                self.error = returnedError
                self.isLoading = false
            }
        }
    }
}
// MARK: - Returning Methods
extension GroupAddPlayersViewModel {
    func getData(at indexPath: IndexPath) -> Users {
        return players[indexPath.row]
    }
    func playerSelected(at indexPath: IndexPath) {
        
    }
}
