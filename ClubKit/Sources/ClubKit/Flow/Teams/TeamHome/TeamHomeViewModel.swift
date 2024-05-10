//
//  File.swift
//  
//
//  Created by Findlay-Personal on 27/05/2023.
//

import Foundation

class TeamHomeViewModel: ObservableObject {
    
    var team: RemoteTeamModel
    
    var selectedAction: ((Action) -> ())?
    
    init(team: RemoteTeamModel) {
        self.team = team
    }
    
    enum Action {
        case players
        case defaultLineup
    }
}
