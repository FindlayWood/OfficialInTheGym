//
//  File.swift
//  
//
//  Created by Findlay Wood on 21/09/2023.
//

import Foundation

protocol ClubCreationViewControllerFactory {
    func makeClubCreationViewController() -> ClubCreationViewController
}

struct BasicClubCreationViewControllerFactory: ClubCreationViewControllerFactory {
    
    var networkService: NetworkService
    var clubManager: ClubManager
    
    func makeClubCreationViewController() -> ClubCreationViewController {
        let client = FirebaseClient(service: networkService)
        let creationService = RemoteCreationService(client: client)
        let viewModel = ClubCreationViewModel(service: creationService, clubManager: clubManager)
        let vc = ClubCreationViewController(viewModel: viewModel)
        return vc
    }
}
