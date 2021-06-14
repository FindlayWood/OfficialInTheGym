//
//  CreateAMRAPProtocol.swift
//  InTheGym
//
//  Created by Findlay Wood on 03/06/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation

protocol CreateAMRAPProtocol {
    func getData(at indexPath: IndexPath) -> exercise
    func addNewExercise()
    func numberOfExercises() -> Int
    func changeTime()
    func timeSelected(newTime: Int)
    func getTime() -> Int
}


