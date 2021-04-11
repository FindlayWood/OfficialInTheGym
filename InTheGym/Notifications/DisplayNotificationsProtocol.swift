//
//  DisplayNotificationsProtocol.swift
//  InTheGym
//
//  Created by Findlay Wood on 15/03/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation

protocol DisplayNotificationsProtocol {
    func getData(at: IndexPath) -> NotificationTableViewModel
    func itemSelected(at: IndexPath)
    func retreiveNumberOfItems() -> Int
    func retreiveNumberOfSections() -> Int
}
