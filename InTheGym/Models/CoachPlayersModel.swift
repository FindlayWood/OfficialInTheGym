//
//  CoachPlayersModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 04/03/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation

// MARK: - Coach Players Model
/// Fetch the keys of players
struct CoachPlayersKeyModel: FirebaseInstance {
    var internalPath: String {
        return "CoachPlayers/\(UserDefaults.currentUser.uid)"
    }
}
