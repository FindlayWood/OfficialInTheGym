//
//  CreateEMOMProtocol.swift
//  InTheGym
//
//  Created by Findlay Wood on 15/09/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation

protocol CreateEMOMProtocol {
    func numberOfExercises() -> Int
    func getData(at indexPath: IndexPath) -> exercise
    func addNewExercise()
}
