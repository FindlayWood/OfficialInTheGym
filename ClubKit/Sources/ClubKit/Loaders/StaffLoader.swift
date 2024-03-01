//
//  File.swift
//  
//
//  Created by Findlay Wood on 25/11/2023.
//

import Foundation

protocol StaffLoader {
    func loadAllStaff(for clubID: String) async throws -> [RemoteStaffModel]
}

class RemoteStaffLoader: StaffLoader {
    
    var networkService: NetworkService
    
    init(networkService: NetworkService) {
        self.networkService = networkService
    }
    
    func loadAllStaff(for clubID: String) async throws -> [RemoteStaffModel] {
        return try await networkService.readAll(at: Constants.staffPath(clubID))
    }
}

struct PreviewStaffLoader: StaffLoader {
    func loadAllStaff(for clubID: String) async throws -> [RemoteStaffModel] {
        return []
    }
}
