//
//  File.swift
//  
//
//  Created by Findlay-Personal on 26/11/2023.
//

import Foundation

protocol QRScannerService {
    func loadUserProfile(for uid: String) async throws -> UserModel
    func addPlayer(with data: AddPlayerQRData) async -> Result<AddPlayerQRData,RemoteQRScannerService.Error>
}

struct AddPlayerQRData {
    let clubID: String
    let userUID: String
    let displayName: String
    let positions: [String]
    let selectedTeams: [String]
}

struct RemoteQRScannerService: QRScannerService {
    
    var networkService: NetworkService
    
    public enum Error: Swift.Error {
        case failed
    }
    
    func loadUserProfile(for uid: String) async throws -> UserModel {
        return try await networkService.read(at: Constants.userPath(uid))
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
            try await networkService.callFunction(named: "addPlayerQR", with: functionData)
            return .success(data)
        } catch {
            return .failure(.failed)
        }
    }
}

struct PreviewScannerService: QRScannerService {
    func loadUserProfile(for uid: String) async throws -> UserModel {
        return .init(id: UUID().uuidString, displayName: "Display Name", username: "UserName")
    }
    func addPlayer(with data: AddPlayerQRData) async -> Result<AddPlayerQRData, RemoteQRScannerService.Error> {
        return .failure(.failed)
    }
}
