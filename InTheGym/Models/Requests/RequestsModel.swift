//
//  RequestsModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 11/03/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation

// MARK: - Request Search Model
struct RequestSearchModel {
    var id: String
}
extension RequestSearchModel: FirebaseInstance {
    var internalPath: String {
        return "PlayerRequests/\(id)"
    }
}
