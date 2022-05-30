//
//  ExerciseSelectionProtocol.swift
//  InTheGym
//
//  Created by Findlay Wood on 03/09/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation

protocol ExerciseSelectionProtocol {
    func getData(at indexPath: IndexPath) -> String
    func numberOfItems(at section: Int) -> Int
    func numberOfSections() -> Int
    func itemSelected(at indexPath: IndexPath)
    func infoButtonSelected(at indexPath: IndexPath)
}
