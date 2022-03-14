//
//  RequestCellModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 14/03/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import Combine

// MARK: - Request Cell Model
class RequestCellModel: Hashable {
    
    @Published var isLoading: Bool
    var id: String
    var user: Users
    
    init(user: Users) {
        self.isLoading = false
        self.user = user
        self.id = UUID().uuidString
    }
    
    static func == (lhs: RequestCellModel, rhs: RequestCellModel) -> Bool {
        rhs.id == lhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
