//
//  RequestCellAction.swift
//  InTheGym
//
//  Created by Findlay Wood on 11/03/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation

// MARK: - Request Cell Action
/// Actions inside request table view cell
enum RequestCellAction {
    case accept(RequestCellModel)
    case decline(RequestCellModel)
    case error
}
