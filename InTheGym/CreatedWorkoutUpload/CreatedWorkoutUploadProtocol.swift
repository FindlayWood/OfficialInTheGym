//
//  CreatedWorkoutUploadProtocol.swift
//  InTheGym
//
//  Created by Findlay Wood on 08/04/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation

protocol CreatedWorkoutUploadDelegate{
    func getData(at indexPath:IndexPath) -> [String:AnyObject]
    func itemSelected(at indexPath:IndexPath)
    func retreiveNumberOfItems() -> Int
}

