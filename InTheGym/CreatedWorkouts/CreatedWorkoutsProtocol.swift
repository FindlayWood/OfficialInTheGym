//
//  CreatedWorkoutsProtocol.swift
//  InTheGym
//
//  Created by Findlay Wood on 01/04/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation

protocol CreatedWorkoutsProtocol {
    func getData(at: IndexPath) -> savedWorkoutDelegate
    func itemSelected(at: IndexPath)
    func retreiveNumberOfItems() -> Int
    func retreiveNumberOfSections() -> Int
}
