//
//  File.swift
//  
//
//  Created by Findlay Wood on 22/11/2023.
//

import Foundation

protocol GroupCreationService {
    func createNewGroup(with data: NewGroupData) async -> Result<NewGroupData,RemoteGroupCreationService.Error>
}

struct NewGroupData {
    let displayName: String
    let clubID: String
    let groupID: String = UUID().uuidString
    let groupName: String
    let members: [String]
}

struct RemoteGroupCreationService: GroupCreationService {
    
    var client: Client
    
    public enum Error: Swift.Error {
        case failed
    }
    
    func createNewGroup(with data: NewGroupData) async -> Result<NewGroupData,Error> {
        let functionData: [String: Any] = [
            "clubID": data.clubID,
            "groupID": data.groupID,
            "groupName": data.groupName,
            "members": data.members
        ]
        do {
            try await client.callFunction(named: "createGroup", with: functionData)
            return .success(data)
        } catch {
            return .failure(.failed)
        }
    }
}

struct PreviewGroupService: GroupCreationService {
    func createNewGroup(with data: NewGroupData) async -> Result<NewGroupData, RemoteGroupCreationService.Error> {
        .failure(.failed)
    }
}
