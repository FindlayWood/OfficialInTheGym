//
//  File.swift
//  
//
//  Created by Findlay-Personal on 22/12/2023.
//

import Foundation

protocol LinkPlayerService {
    func linkPlayer(with data: LinkPlayerQRData) async -> Result<LinkPlayerQRData,RemoteQRScannerService.Error>
}

struct LinkPlayerQRData {
    let clubID: String
    let userUID: String
    let playerID: String
}

struct RemoteLinkPlayerService: LinkPlayerService {
    
    var networkService: NetworkService
    
    public enum Error: Swift.Error {
        case failed
    }
    
    func linkPlayer(with data: LinkPlayerQRData) async -> Result<LinkPlayerQRData,RemoteQRScannerService.Error> {
        
        let functionData: [String: Any] = [
            "clubID": data.clubID,
            "userUID": data.userUID,
            "playerID": data.playerID
        ]
        do {
            try await networkService.callFunction(named: "linkPlayerAccount", with: functionData)
            return .success(data)
        } catch {
            return .failure(.failed)
        }
    }
}

struct PreviewLinkPlayerService: LinkPlayerService {
    func linkPlayer(with data: LinkPlayerQRData) async -> Result<LinkPlayerQRData, RemoteQRScannerService.Error> {
        return .failure(.failed)
    }
}
