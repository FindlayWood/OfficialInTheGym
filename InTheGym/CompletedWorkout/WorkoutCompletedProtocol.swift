//
//  WorkoutCompletedProtocol.swift
//  InTheGym
//
//  Created by Findlay Wood on 04/04/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation

protocol WorkoutCompletedProtocol {
    func getData(at indexPath: IndexPath) -> [String:AnyObject]
    func isPrivate() -> Bool
    func isPosting() -> Bool
    func itemSelected(at indexPath: IndexPath)
    func retreiveNumberOfItems() -> Int
    func retreiveNumberOfSections() -> Int
}
