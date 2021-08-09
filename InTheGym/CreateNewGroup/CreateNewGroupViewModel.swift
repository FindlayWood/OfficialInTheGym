//
//  CreateNewGroupViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 09/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation

class CreateNewGroupViewModel {
    
    // MARK: - Closures
    var reloadTableViewClosure: (() -> ())?
    
    // MARK: - Properties
    var addedPlayers: [Users] = [] {
        didSet {
            reloadTableViewClosure?()
        }
    }
    
    var numberOfItems: Int {
        return addedPlayers.count
    }
    
    func getData(at indexPath: IndexPath) -> Users {
        return addedPlayers[indexPath.row]
    }
    func addNewPlayers(_ players: [Users]) {
        addedPlayers.append(contentsOf: players)
    }
}
