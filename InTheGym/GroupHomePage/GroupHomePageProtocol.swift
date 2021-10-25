//
//  GroupHomePageProtocol.swift
//  InTheGym
//
//  Created by Findlay Wood on 12/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

protocol GroupHomePageProtocol: TimelineTapProtocol {
    func getGroupInfo() -> groupModel
    func getPostData(at indexPath: IndexPath) -> post
    func numberOfPosts() -> Int
    func postSelected(at indexPath: IndexPath)
    func getGroupImage() -> UIImage?
    func numberOfMembers() -> Int
    func scrolledTo(headerInView: Bool)
    func postsLoaded() -> Bool
    func getGroupLeader() -> Users
    func leaderLoaded() -> Bool
    func newInfoSaved(_ newInfo: MoreGroupInfoModel)
    func goToWorkouts()
    func showGroupMembers()
    func isCurrentUserLeader() -> Bool
    func manageGroup()
}

