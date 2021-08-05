//
//  DisplayWokoutStatsProtocol.swift
//  InTheGym
//
//  Created by Findlay Wood on 24/06/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation

protocol WorkoutStatsProtocol {
    func getData(at indexPath: IndexPath) -> WorkoutStatCellModel
    func numberOfCells() -> Int
}
