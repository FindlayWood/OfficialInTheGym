//
//  DisplayCircuitProtocol.swift
//  InTheGym
//
//  Created by Findlay Wood on 28/04/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

protocol DisplayCircuitProtocol{
    func getData(at indexPath:IndexPath) -> CircuitTableModel
    func retreiveNumberOfExercises() -> Int
    func exerciseCompleted(at indexPath:IndexPath)
    func completedExercise(on cell:UITableViewCell)
    func isButtonInteractionEnabled() -> Bool
}
