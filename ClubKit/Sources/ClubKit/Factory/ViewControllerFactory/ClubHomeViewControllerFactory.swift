//
//  File.swift
//  
//
//  Created by Findlay Wood on 21/09/2023.
//

import Foundation

protocol ClubHomeViewControllerFactory {
    func makeClubHomeViewController(with model: RemoteClubModel) -> ClubHomeViewController
}

struct BasicClubHomeViewControllerFactory: ClubHomeViewControllerFactory {
    
    func makeClubHomeViewController(with model: RemoteClubModel) -> ClubHomeViewController {
        let vc = ClubHomeViewController(clubModel: model)
        return vc
    }
}
