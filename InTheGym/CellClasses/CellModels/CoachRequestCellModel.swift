//
//  CoachRequestCellModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 31/05/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation

struct CoachRequestCellModel: Hashable {
    var id = UUID()
    var user: Users
    var requestStatus: RequestStatus
    
    enum RequestStatus: String {
        case accepted = "Accepted"
        case sent = "Sent"
        case none = "Send Request"
    }
}
