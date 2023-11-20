//
//  File.swift
//  
//
//  Created by Findlay Wood on 19/11/2023.
//

import Foundation

protocol GroupLoader {
    func loadAllGroups(for clubID: String) async throws -> [RemoteGroupModel]
}

class RemoteGroupLoader: GroupLoader {
    
    var networkService: NetworkService
    
    init(networkService: NetworkService) {
        self.networkService = networkService
    }
    
    func loadAllGroups(for clubID: String) async throws -> [RemoteGroupModel] {
        return try await networkService.readAll(at: Constants.groupsPath(clubID))
    }
}

class PreviewGroupLoader: GroupLoader {
    func loadAllGroups(for clubID: String) async throws -> [RemoteGroupModel] {
        return []
    }
}
