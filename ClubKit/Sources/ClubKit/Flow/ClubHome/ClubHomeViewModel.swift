//
//  File.swift
//  
//
//  Created by Findlay-Personal on 14/05/2023.
//

import Foundation

class ClubHomeViewModel: ObservableObject {
    
    var clubModel: RemoteClubModel
    
    init(clubModel: RemoteClubModel) {
        self.clubModel = clubModel
    }
}
