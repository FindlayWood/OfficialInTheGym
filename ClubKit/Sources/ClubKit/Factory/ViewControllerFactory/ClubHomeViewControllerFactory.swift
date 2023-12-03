//
//  File.swift
//  
//
//  Created by Findlay Wood on 21/09/2023.
//

import Foundation

protocol ClubHomeViewControllerFactory {
    func makeClubHomeViewController(with model: RemoteClubModel) -> ClubHomeViewController
    func makeQRScannerViewController(with model: RemoteClubModel) -> QRScannerViewController
}

struct BasicClubHomeViewControllerFactory: ClubHomeViewControllerFactory {
    
    let qrScannerService: QRScannerService
    let playerLoader: PlayerLoader
    let teamLoader: TeamLoader
    let creationService: PlayerCreationService
    
    func makeClubHomeViewController(with model: RemoteClubModel) -> ClubHomeViewController {
        let vc = ClubHomeViewController(clubModel: model)
        return vc
    }
    
    func makeQRScannerViewController(with model: RemoteClubModel) -> QRScannerViewController {
        let viewModel = QRScannerViewModel(scannerService: qrScannerService,
                                           clubModel: model,
                                           loader: playerLoader,
                                           teamLoader: teamLoader,
                                           creationService: creationService)
        let vc = QRScannerViewController(viewModel: viewModel)
        return vc
    }
}
