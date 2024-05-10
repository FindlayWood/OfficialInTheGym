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
        case linking
        case alreadyJoined
        case gotUserProfile(UserModel)
        case success
        case error
    }
    
    @Published var viewState: QRScannerViewState = .scanning
    
    // MARK: - Dependencies
    var clubModel: RemoteClubModel
    let playerModel: RemotePlayerModel
    var loader: PlayerLoader
    var linkService: LinkPlayerService
    // MARK: - Loading Variables
    @Published var isUploading: Bool = false
    @Published var uploaded: Bool = false
    @Published var errorUploading: Bool = false
    
    let scannerService: QRScannerService
    
    init(scannerService: QRScannerService, clubModel: RemoteClubModel, loader: PlayerLoader, playerModel: RemotePlayerModel, linkService: LinkPlayerService) {
        self.scannerService = scannerService
        self.clubModel = clubModel
        self.loader = loader
        self.playerModel = playerModel
        self.linkService = linkService
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
            
            if clubModel.linkedUserUIDs.contains(userUID) {
                viewState = .alreadyJoined
            } else {
                viewState = .gotUserProfile(newUserModel)
            }
            
        case .failure(let failure):
            print(failure.localizedDescription)
        }
    }
    
    @MainActor
    func link(to model: UserModel) async {
        isUploading = true
        viewState = .linking
        let linkData = LinkPlayerQRData(clubID: clubModel.id, userUID: model.id, playerID: playerModel.id)
        let result = await linkService.linkPlayer(with: linkData)
        switch result {
        case .success(let success):
            print("Success")
            self.viewState = .success
        case .failure(let failure):
            print("failure")
            self.viewState = .error
        }
    }
}
