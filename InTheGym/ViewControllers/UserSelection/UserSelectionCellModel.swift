//
//  UserSelectionCellModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 05/05/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation

/// A cell Model that allows for multiple selections
struct UserSelectionCellModel: Hashable {
    
    // Whether this cell has been selected
    var isSelected: Bool
    
    // The user for this cell
    var user: Users
    
    // id for this cell
    var id = UUID()
}
