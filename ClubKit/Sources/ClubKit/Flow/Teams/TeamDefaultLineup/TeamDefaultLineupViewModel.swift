//
//  File.swift
//  
//
//  Created by Findlay-Personal on 07/06/2023.
//

import Foundation

class TeamDefaultLineupViewModel: ObservableObject {
    
    @Published var isEditing: Bool = false
    
    var team: RemoteTeamModel
    
    init(team: RemoteTeamModel) {
        self.team = team
    }
}
