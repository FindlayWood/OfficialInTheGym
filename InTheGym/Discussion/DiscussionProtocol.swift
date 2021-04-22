//
//  DiscussionProtocol.swift
//  InTheGym
//
//  Created by Findlay Wood on 25/03/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation

protocol DiscussionProtocol {
    func getOriginalPost() -> PostProtocol
    func getData(at:IndexPath) -> PostProtocol
    func retreiveNumberOfItems() -> Int
    func retreiveNumberOfSections() -> Int
    func itemSelected(at: IndexPath)
    func replyPosted()
}

protocol DiscussionCellConfigurable {
    func setup(rowViewModel:PostProtocol)
    var delegate:DiscussionTapProtocol! { get set }
}
