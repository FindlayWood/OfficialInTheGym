//
//  ProgressViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 21/02/2020.
//  Copyright © 2020 FindlayWood. All rights reserved.
//

import UIKit
import Charts

class ProgressViewController: UIViewController {
    
    // outlet to chart view
    @IBOutlet weak var lineChart:LineChartView!
    
    // array for chart values
    var lineChartEntry = [ChartDataEntry]()
    var numbers : [Int] = [3,5,6,8,5,9,12]
    
    func updateGraph(){
        
        for i in 0..<numbers.count{
            let value = ChartDataEntry(x: Double(i), y: Double(numbers[i]))
            lineChartEntry.append(value)
        }
        let line1 = LineChartDataSet(entries: lineChartEntry, label: "numbers")
        line1.colors = [UIColor.blue]
        let data = LineChartData()
        data.addDataSet(line1)
        lineChart.data = data
        lineChart.chartDescription?.text = "numbers description"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateGraph()

        
    }
    

}
