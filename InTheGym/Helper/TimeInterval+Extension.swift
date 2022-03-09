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
        let date = Date(timeIntervalSince1970: self)
        let days = Calendar.current.dateComponents([.day], from: date, to: Date())
        return days.day ?? 0
    }
}
