//
//  PreLiveWorkoutProtocol.swift
//  InTheGym
//
//  Created by Findlay Wood on 31/07/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation

protocol PreLiveWorkoutProtocol {
    func getData(at indexPath: IndexPath) -> String
    func numberOfRows() -> Int
    func itemSelected(at indexPath: IndexPath)
}
