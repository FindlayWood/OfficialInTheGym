//
//  ACWRChartYAxisFormatter.swift
//  InTheGym
//
//  Created by Findlay Wood on 11/06/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import Charts

final class ACWRChartXAxisFormatter: IndexAxisValueFormatter {
    override func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let currentDate = Date()
        let daysAgo = 27 - Int(value)
        guard let newDate = currentDate.addOrSubtractDay(day: -daysAgo) else { return "" }
        return newDate.getDayMonthFormat()
    }
}
