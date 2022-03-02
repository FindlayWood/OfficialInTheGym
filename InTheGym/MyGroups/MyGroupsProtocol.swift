//
//  MyGroupsProtocol.swift
//  InTheGym
//
//  Created by Findlay Wood on 07/04/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation

protocol MyGroupsProtocol {
    func getGroup(at indexPath:IndexPath) -> GroupModel
    func groupSelected(at indexPath:IndexPath)
    func retreiveNumberOfGroups() -> Int
    func addedNewGroup()
}
