//
//  File.swift
//  
//
//  Created by Findlay-Personal on 14/05/2023.
//

import Foundation

protocol ViewControllerFactory {
    func makeClubsViewController(flow: ClubsFlow) -> ClubsViewController
    func makeClubCreationViewController() -> ClubCreationViewController
    func makeClubHomeViewController(_ model: RemoteClubModel) -> ClubHomeViewController
}

class RegularViewControllerFactory: ViewControllerFactory {
    var clubManager: ClubManager
    
    init(clubManager: ClubManager) {
        self.clubManager = clubManager
    }
    
    func makeClubsViewController(flow: ClubsFlow) -> ClubsViewController {
        let vc = ClubsViewController(clubManager: clubManager, coordinator: flow)
        return vc
    }
    
    func makeClubCreationViewController() -> ClubCreationViewController {
        let vc = ClubCreationViewController()
        return vc
    }
    
    func makeClubHomeViewController(_ model: RemoteClubModel) -> ClubHomeViewController {
        let vc = ClubHomeViewController(clubModel: model)
        return vc
    }
}
