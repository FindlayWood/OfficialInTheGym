//
//  MyProgramsItems.swift
//  InTheGym
//
//  Created by Findlay Wood on 25/02/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation

enum MyProgramsItems: Hashable {
    case program(ProgramModel)
    case savedProgram(SavedProgramModel)
}
