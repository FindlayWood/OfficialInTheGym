//
//  CreateNewGroupProtocol.swift
//  InTheGym
//
//  Created by Findlay Wood on 09/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation

protocol CreateNewGroupProtocol {
    func getData(at indexPath: IndexPath) -> Users
    func numberOfItems() -> Int
    func addPlayers()
}

protocol GroupAddPlayersProtocol {
    func getPlayerData(at indexPath: IndexPath) -> Users
    func numberOfPlayers() -> Int
    func checkIfPlayerSelected(_ player: Users) -> Bool
    func playerSelected(at indexPath: IndexPath)
}

protocol AddedPlayersProtocol {
    func newPlayersAdded(_ players: [Users])
}
