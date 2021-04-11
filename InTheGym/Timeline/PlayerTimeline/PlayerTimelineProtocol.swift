//
//  PlayerTimelineProtocol.swift
//  InTheGym
//
//  Created by Findlay Wood on 15/03/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation

protocol PlayerTimelineProtocol: class {
    func getData(at:IndexPath) -> PostProtocol
    func itemSelected(at: IndexPath)
    func retreiveNumberOfItems() -> Int
    func retreiveNumberOfSections() -> Int
    func newPosts()
}
