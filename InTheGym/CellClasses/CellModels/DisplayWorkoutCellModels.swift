//
//  DisplayWorkoutCellModels.swift
//  InTheGym
//
//  Created by Findlay Wood on 07/03/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

struct TableViewCellModel{
    var title:String?
    var setCollections:[[CollectionCellModel]]?
}

struct CollectionCellModel{
    var set:Int?
    var weight:String?
    var completed:Bool?
    var reps:String?
    var parentTableViewCell:UITableViewCell?
}
