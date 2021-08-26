//
//  AddMoreToExerciseProtocol.swift
//  InTheGym
//
//  Created by Findlay Wood on 21/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation

protocol AddMoreToExerciseProtocol {
    func getData(at indexPath: IndexPath) -> SwiftUICardContent
    func numberOfItems() -> Int
    func itemSelected(at indexPath: IndexPath)
}
