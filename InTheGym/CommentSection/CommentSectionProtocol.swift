//
//  CommentSectionProtocol.swift
//  InTheGym
//
//  Created by Findlay Wood on 17/03/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation

protocol CommentSectionProtocol {
    func getData(at:IndexPath) -> PostProtocol
    func itemSelected(at: IndexPath)
    func retreiveNumberOfItems() -> Int
    func retreiveNumberOfSections() -> Int
}
