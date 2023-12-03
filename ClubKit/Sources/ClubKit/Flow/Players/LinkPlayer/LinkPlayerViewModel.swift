//
//  File.swift
//  
//
//  Created by Findlay-Personal on 03/12/2023.
//

import Foundation

class LinkPlayerViewModel: ObservableObject {
    
    public enum QRScannerViewState {
        case scanning
        case scanError
        case loadingScan
        case gotUserProfile(UserModel)
    }
    
    @Published var viewState: QRScannerViewState = .scanning
    
    // MARK: - Dependencies
    var clubModel: RemoteClubModel
    let playerModel: RemotePlayerModel
    var loader: PlayerLoader
    var creationService: PlayerCreationService
    // MARK: - Loading Variables
    @Published var isUploading: Bool = false
    @Published var uploaded: Bool = false
    @Published var errorUploading: Bool = false
    
    let scannerService: QRScannerService
    
    init(scannerService: QRScannerService, clubModel: RemoteClubModel, loader: PlayerLoader, playerModel: RemotePlayerModel, creationService: PlayerCreationService) {
        self.scannerService = scannerService
        self.clubModel = clubModel
        self.loader = loader
        self.playerModel = playerModel
        self.creationService = creationService
    }
    
    func handleScan(result: Result<ScanResult, ScanError>) {
        viewState = .loadingScan
        switch result {
        case .success(let success):
            let details = success.string.components(separatedBy: QRConstants.separatingCode)
            guard details.count == 5,
                  details.first == QRConstants.startCode,
                  details.last == QRConstants.endCode else {
                viewState = .scanError
                return }
            
            let userUID = details[1]
            let displayName = details[2]
            let username = details[3]
            
            let newUserModel = UserModel(id: userUID, displayName: displayName, username: username)
            viewState = .gotUserProfile(newUserModel)
            
            
        case .failure(let failure):
            print(failure.localizedDescription)
        }
    }
    
    @MainActor
    func create() async {
        isUploading = true

    }
}
