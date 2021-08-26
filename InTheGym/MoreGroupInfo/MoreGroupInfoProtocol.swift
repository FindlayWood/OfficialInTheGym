//
//  MoreGroupInfoProtocol.swift
//  InTheGym
//
//  Created by Findlay Wood on 15/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

protocol MoreGroupInfoProtocol {
    func getData(at indexPath: IndexPath) -> String
    func returnLeader() -> Users?
    func isLeaderLoaded() -> Bool
    func membersLoaded() -> Bool
    func getMember(at indexPath: IndexPath) -> Users
    func numberOfMembers() -> Int
}

struct MoreGroupInfoModel {
    var leader: Users?
    var headerImage: UIImage?
    var description: String?
    var groupName: String!
    var groupID: String!
    var leaderID: String!
}
