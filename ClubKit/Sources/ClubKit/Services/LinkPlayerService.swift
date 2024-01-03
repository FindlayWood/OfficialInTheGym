//
//  File.swift
//  
//
//  Created by Findlay-Personal on 22/12/2023.
//

import Foundation

protocol LinkPlayerService {
    func addPlayer(with data: AddPlayerQRData) async -> Result<AddPlayerQRData,RemoteQRScannerService.Error>
}

struct LinkPlayerQRData {
    let clubID: String
    let userUID: String
    let displayName: String
    let positions: [String]
    let selectedTeams: [String]
}

struct RemoteLinkPlayerService: LinkPlayerService {
    
    var networkService: NetworkService
    
    public enum Error: Swift.Error {
        case failed
    }
    
    func addPlayer(with data: AddPlayerQRData) async -> Result<AddPlayerQRData,RemoteQRScannerService.Error> {
        
        let functionData: [String: Any] = [
            "clubID": data.clubID,
            "uid": data.userUID,
            "displayName": data.displayName,
            "positions": data.positions,
            "selectedTeams": data.selectedTeams
        ]
        do {
            try await networkService.callFunction(named: "linkPlayer", with: functionData)
            return .success(data)
        } catch {
            return .failure(.failed)
        }
    }
}

struct PreviewLinkPlayerService: LinkPlayerService {
    func addPlayer(with data: AddPlayerQRData) async -> Result<AddPlayerQRData, RemoteQRScannerService.Error> {
        return .failure(.failed)
    }
}
