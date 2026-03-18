//
//  File.swift
//  
//
//  Created by Findlay Wood on 25/11/2023.
//

import Foundation

protocol StaffCreationService {
    func createNewStaff(with data: NewStaffData) async -> Result<NewStaffData,RemoteStaffCreationService.Error>
}

struct NewStaffData {
    let id: String
    let displayName: String
    let clubID: String
    let role: StaffRoles
    let teams: [String]
    let isAdmin: Bool
}

struct RemoteStaffCreationService: StaffCreationService {
    
    var client: Client
    
    public enum Error: Swift.Error {
        case failed
    }
    
    func createNewStaff(with data: NewStaffData) async -> Result<NewStaffData,Error> {
        let functionData: [String: Any] = [
            "clubID": data.clubID,
            "id": data.id,
            "displayName": data.displayName,
            "role": data.role.rawValue,
            "selectedTeams": data.teams,
            "isAdmin": data.isAdmin
        ]
        do {
            try await client.callFunction(named: "createStaff", with: functionData)
            return .success(data)
        } catch {
            return .failure(.failed)
        }
    }
}

struct PreviewStaffService: StaffCreationService {
    func createNewStaff(with data: NewStaffData) async -> Result<NewStaffData, RemoteStaffCreationService.Error> {
        .failure(.failed)
    }
}
