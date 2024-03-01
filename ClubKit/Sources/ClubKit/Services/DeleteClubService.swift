//
//  DeleteClubService.swift
//  
//
//  Created by Findlay Wood on 17/02/2024.
//

import Foundation

protocol DeleteClubService {
    func deleteClub(with data: DeleteClubData) async -> Result<DeleteClubData,RemoteDeleteClubService.Error>
}


struct DeleteClubData {
    let id: String
    let linkedUserUIDs: [String]
}

struct RemoteDeleteClubService: DeleteClubService {
    
    var client: Client
    
    public enum Error: Swift.Error {
        case failed
    }
    
    func deleteClub(with data: DeleteClubData) async -> Result<DeleteClubData,Error> {
        let functionData = [
            FunctionKeys.DeleteClubFunction.id: data.id,
            FunctionKeys.DeleteClubFunction.linkedUserUIDs: data.linkedUserUIDs
        ] as [String : Any]
        do {
            try await client.callFunction(named: FirebaseFunctionsConstants.deleteClub, with: functionData)
            return .success(data)
        } catch {
            return .failure(.failed)
        }
    }
}

struct PreviewDeleteClubService: DeleteClubService {
    func deleteClub(with data: DeleteClubData) async -> Result<DeleteClubData, RemoteDeleteClubService.Error> {
        .failure(.failed)
    }
}
