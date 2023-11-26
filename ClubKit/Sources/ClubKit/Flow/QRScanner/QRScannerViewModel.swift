//
//  File.swift
//  
//
//  Created by Findlay-Personal on 26/11/2023.
//

import Foundation

class QRScannerViewModel: ObservableObject {
    
    public enum QRScannerViewState {
        case scanning
        case scanError
        case loadingScan
        case gotPlayerUID(String)
        case loadingUserProfile
        case gotUserProfile(UserModel)
        case loadingPlayerCreation
        case playerCreationSuccess
        case playerCreationError
    }
    
    @Published var viewState: QRScannerViewState = .scanning
    
    let scannerService: QRScannerService
    
    init(scannerService: QRScannerService) {
        self.scannerService = scannerService
    }
    
    func handleScan(result: Result<ScanResult, ScanError>) {
        switch result {
        case .success(let success):
            let userUID = success.string
            
        case .failure(let failure):
            print(failure.localizedDescription)
        }
        viewState = .loadingScan
    }
    
    func getUserProfile(_ uid: String) {
        viewState = .loadingUserProfile
        Task {
            do {
                let userProfile = try await scannerService.loadUserProfile(for: uid)
                viewState = .gotUserProfile(userProfile)
            } catch {
                print(String(describing: error))
            }
        }
    }
}
