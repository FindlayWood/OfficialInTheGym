//
//  UploadingWorkoutProtocol.swift
//  InTheGym
//
//  Created by Findlay Wood on 23/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

protocol UploadingWorkoutProtocol: UploadingCellActions {
    func getData(at indexPath: IndexPath) -> UploadCellModelProtocol
    func numberOfItems() -> Int
    func itemSelected(at indexPath: IndexPath)
}
protocol UploadingCellActions: AnyObject {
    func savingSwitchChanged()
    func privacyChanged()
}
