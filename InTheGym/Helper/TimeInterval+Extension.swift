//
//  TimeInterval+Extension.swift
//  InTheGym
//
//  Created by Findlay Wood on 07/03/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation

extension TimeInterval {
    func daysAgo() -> Int {
        let fromDate = Calendar.current.startOfDay(for: Date(timeIntervalSince1970: self))
        let toDate = Calendar.current.startOfDay(for: Date())
        let days = Calendar.current.dateComponents([.day], from: fromDate, to: toDate)
        return days.day ?? 0
    }
}
