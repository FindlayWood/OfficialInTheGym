//
//  TagAndExerciseCellModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 26/05/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation

struct TagAndExerciseCellModel: Hashable {
    var tag: String
    var exercise: String
    var id: String = UUID().uuidString
}
