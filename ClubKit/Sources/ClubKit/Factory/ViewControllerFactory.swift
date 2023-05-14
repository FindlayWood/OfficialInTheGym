//
//  File.swift
//  
//
//  Created by Findlay-Personal on 14/05/2023.
//

import Foundation

protocol ViewControllerFactory {
    func makeClubsViewController() -> ClubsViewController
}

class RegularViewControllerFactory: ViewControllerFactory {
    var clubManager: ClubManager
    
    init(clubManager: ClubManager) {
        self.clubManager = clubManager
    }
    
    func makeClubsViewController() -> ClubsViewController {
        let vc = ClubsViewController(clubManager: clubManager)
        return vc
    }
}
