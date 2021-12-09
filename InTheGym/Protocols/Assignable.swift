//
//  Assignable.swift
//  InTheGym
//
//  Created by Findlay Wood on 23/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation

/// a type that can have a workout assigned to it
protocol Assignable {
    
    /// currently the two types of assignable are Users and groupModel
    /// workouts can be assigned to either of these types
    /// the username of groupModel is the name of the group
    
    /// username variable - the name of the assigned type
    var username: String { get }
    
    /// uid variable - the id of the assigned type
    var uid: String { get }
}
