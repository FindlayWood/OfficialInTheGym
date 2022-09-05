//
//  Calendar+Extension.swift
//  InTheGym
//
//  Created by Findlay Wood on 19/08/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation

extension Calendar {
    func numberOfDaysBetween(_ from: Date, and to: Date) -> Int {
        let fromDate = startOfDay(for: from)
        let toDate = startOfDay(for: to)
        let numberOfDays = dateComponents([.day], from: fromDate, to: toDate)
        
        return numberOfDays.day!
    }
}
