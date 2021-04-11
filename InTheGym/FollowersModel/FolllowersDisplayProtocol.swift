//
//  FolllowersDisplayProtocol.swift
//  InTheGym
//
//  Created by Findlay Wood on 12/03/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation


protocol FollowersDisplayProtocol {
    func getData(at: IndexPath) -> Users
    func itemSelected(at: IndexPath)
    func retreiveNumberOfItems() -> Int
    func retreiveNumberOfSections() -> Int
}
