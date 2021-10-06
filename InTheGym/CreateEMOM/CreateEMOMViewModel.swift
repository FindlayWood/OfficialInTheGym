//
//  CreateEMOMViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 16/09/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation

class CreateEMOMViewModel {
    
    // MARK: - Properties
    var navigationTitle = "Create EMOM"
    
    // MARK: - Callbacks
    var reloadTableViewClosure: (()->())?
    
    var exercises = [exercise]() {
        didSet {
            reloadTableViewClosure?()
        }
    }
    
    var numberOfExercises: Int {
        return exercises.count + 1
    }
    
    
    func getData(at indexPath: IndexPath) -> exercise {
        return exercises[indexPath.section]
    }
}
