//
//  AddingCircuitExerciseProtocol.swift
//  InTheGym
//
//  Created by Findlay Wood on 27/04/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

protocol AddingCircuitExerciseDelegate {
    func addedNewCircuitExercise(with circuitModel:circuitExercise)
}
protocol CircuitOptionsDelegate {
    func valueChanged(on cell:UITableViewCell)
}

