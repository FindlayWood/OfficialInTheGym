//
//  File.swift
//  
//
//  Created by Findlay Wood on 19/11/2023.
//

import Foundation

protocol GroupLoader {
    func loadAllGroups(for clubID: String) async throws -> [RemoteGroupModel]
    func loadGroup(with groupID: String, from clubID: String) async throws -> RemoteGroupModel
}

class RemoteGroupLoader: GroupLoader {
    
    var networkService: NetworkService
    
    init(networkService: NetworkService) {
        self.networkService = networkService
    }
    
    func loadAllGroups(for clubID: String) async throws -> [RemoteGroupModel] {
        return try await networkService.readAll(at: Constants.groupsPath(clubID))
    }
    func loadGroup(with groupID: String, from clubID: String) async throws -> RemoteGroupModel {
        return try await networkService.read(at: Constants.groupPath(for: groupID, from: clubID))
    }
}

class PreviewGroupLoader: GroupLoader {
    func loadAllGroups(for clubID: String) async throws -> [RemoteGroupModel] {
        return []
    }
    func loadGroup(with groupID: String, from clubID: String) async throws -> RemoteGroupModel {
        return .example
    }
}
