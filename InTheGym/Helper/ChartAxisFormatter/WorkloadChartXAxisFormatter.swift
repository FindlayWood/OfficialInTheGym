//
//  WorkloadChartXAxisFormatter.swift
//  InTheGym
//
//  Created by Findlay Wood on 12/06/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import Charts

class WorkloadChartXAxisFormatter: IndexAxisValueFormatter {
    /// the x axis maximum
    var days: Int
    // MARK: - Initializer
    init(days: Int) {
        self.days = days
        super.init()
    }
    override func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let currentDate = Date()
        let daysAgo = days - Int(value + 1) // plus one as chart values are zero indexed
        guard let newDate = currentDate.addOrSubtractDay(day: -daysAgo) else { return "" }
        return newDate.getDayMonthFormat()
    }
}
