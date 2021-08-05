//
//  CreateCircuitProtocol.swift
//  InTheGym
//
//  Created by Findlay Wood on 26/04/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation

protocol CreateCircuitDelegate {
    func getData(at indexPath:IndexPath) -> exercise
    func retreiveNumberOfItems() -> Int
    func addNewExercise()
}
