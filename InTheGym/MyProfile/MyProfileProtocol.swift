//
//  MyProfileProtocol.swift
//  InTheGym
//
//  Created by Findlay Wood on 31/03/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation

protocol MyProfileProtocol: class {
    func getData(at: IndexPath) -> PostProtocol
    func getCollectionData() -> [[String:AnyObject]]
    func itemSelected(at: IndexPath)
    func collectionItemSelected(at: IndexPath)
    func retreiveNumberOfItems() -> Int
    func retreiveNumberOfSections() -> Int
    func returnFollowerCounts(followerCount:Int, FollowingCount:Int)
}
