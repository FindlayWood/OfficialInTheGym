//
//  GroupPageProtocol.swift
//  InTheGym
//
//  Created by Findlay Wood on 07/04/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation

protocol GroupPageProtocol {
    func getPostData(at indexPath:IndexPath) -> PostProtocol
    func getMemberData(at indexPath:IndexPath) -> Users
    func postSelected(at indexPath:IndexPath)
    func memberSelected(at indexPath:IndexPath)
    func retreiveNumberOfPosts() -> Int
    func retreiveNumberOfMembers() -> Int
    func madeAPost()
}
