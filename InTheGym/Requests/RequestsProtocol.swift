//
//  RequestsProtocol.swift
//  InTheGym
//
//  Created by Findlay Wood on 18/03/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

protocol RequestsProtocol{
    func getData(at: IndexPath) -> Users
    func itemSelected(at: IndexPath)
    func retreiveNumberOfItems() -> Int
    func retreiveNumberOfSections() -> Int
}

protocol buttonTapsRequestDelegate{
    func acceptRequest(from user:Users, on: UITableViewCell)
    func declineRequest(from user:Users, on: UITableViewCell)
    func userTapped(on user:Users)
}
