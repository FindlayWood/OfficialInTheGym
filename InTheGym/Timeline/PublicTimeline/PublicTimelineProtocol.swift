//
//  PublicTimelineProtocol.swift
//  InTheGym
//
//  Created by Findlay Wood on 23/03/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit
import Firebase

protocol PublicTimelineProtocol: class {
    func getData(at:IndexPath) -> PostProtocol
    func itemSelected(at: IndexPath)
    func retreiveNumberOfItems() -> Int
    func retreiveNumberOfSections() -> Int
    func returnFollowerCounts(followerCount:Int, FollowingCount:Int)
    func returnIsFollowing(following:Bool)
    func reloadTableviewRow(at: IndexPath)
    func newPosts()
}

protocol CellConfiguarable{
    func setup(rowViewModel: PostProtocol)
    var delegate:TimelineTapProtocol! { get set }
}

