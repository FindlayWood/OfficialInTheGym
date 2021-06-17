//
//  CreateAMRAPViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 03/06/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation

class CreateAMRAPViewModel {
    
    var reloadTableViewClosure: (() -> ())?
    
    var exercises: [exercise] = [] {
        didSet{
            reloadTableViewClosure?()
        }
    }
    
    var numberOfExercises: Int {
        return exercises.count
    }
    
    
}
