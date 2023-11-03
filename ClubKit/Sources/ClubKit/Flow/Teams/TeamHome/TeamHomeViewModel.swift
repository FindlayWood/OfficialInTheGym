//
//  File.swift
//  
//
//  Created by Findlay-Personal on 27/05/2023.
//

import Foundation

class TeamHomeViewModel: ObservableObject {
    
    var team: RemoteTeamModel
    
    init(team: RemoteTeamModel) {
        self.team = team
    }
}
