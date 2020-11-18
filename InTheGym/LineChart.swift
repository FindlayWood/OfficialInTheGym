//
//  LineChart.swift
//  InTheGym
//
//  Created by Findlay Wood on 17/11/2020.
//  Copyright © 2020 FindlayWood. All rights reserved.
//

import Foundation
import Charts

class LineChart: UIView, ChartViewDelegate {
    
    let lineChartView = LineChartView()
    var lineDataEntry : [ChartDataEntry] = []
    
    var workoutDuration = [Int]()
    var beatsPerMinute = [Int]()
    var size = Int()
    
    var delegate : GetChartData! {
        didSet{
            populateData()
            lineChartSetup()
        }
    }
    
    func populateData(){
        self.workoutDuration = delegate.workoutLoad
        self.beatsPerMinute = delegate.dates
        self.size = delegate.size
    }
    
    func lineChartSetup(){
        self.backgroundColor = .white
        self.addSubview(lineChartView)
        lineChartView.translatesAutoresizingMaskIntoConstraints = false
        lineChartView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        lineChartView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        lineChartView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        lineChartView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        lineChartView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0, easingOption: .easeInOutSine)
        lineChartView.xAxis.axisMinimum = 0.0
        lineChartView.xAxis.axisMaximum = Double(size)
        lineChartView.xAxis.labelPosition = XAxis.LabelPosition.bottom
        lineChartView.rightAxis.drawAxisLineEnabled = false
        lineChartView.isUserInteractionEnabled = false
        
        setChartData(dataPoints: workoutDuration, values: beatsPerMinute, size: size)
    }
    
    func setChartData(dataPoints: [Int], values: [Int], size: Int){
        
        lineChartView.noDataTextColor = .black
        lineChartView.noDataText = "NO DATA"
        lineChartView.backgroundColor = .white
        
        //lineDataEntry.append(ChartDataEntry(x: 0.0, y: 0.0))
        
        for i in 0..<dataPoints.count{
            let datapoint = ChartDataEntry(x: Double(dataPoints[i]), y: Double(values[i]))
            lineDataEntry.append(datapoint)
        }
        
        //lineDataEntry.append(ChartDataEntry(x: Double(size), y: 0.0))
        
        let chartDataSet = LineChartDataSet(entries: lineDataEntry, label: "workload")
        let chartData = LineChartData()
        chartData.addDataSet(chartDataSet)
        chartData.setDrawValues(true)
        chartDataSet.colors = [#colorLiteral(red: 0, green: 0.5, blue: 1, alpha: 1), #colorLiteral(red: 0.6332940925, green: 0.8493953339, blue: 1, alpha: 1), #colorLiteral(red: 0.7802333048, green: 1, blue: 0.5992883134, alpha: 1), #colorLiteral(red: 0.9427440068, green: 1, blue: 0.3910798373, alpha: 1), #colorLiteral(red: 1, green: 1, blue: 0, alpha: 1), #colorLiteral(red: 1, green: 0.8438837757, blue: 0, alpha: 1), #colorLiteral(red: 1, green: 0.7074058219, blue: 0, alpha: 1), #colorLiteral(red: 1, green: 0.4706228596, blue: 0, alpha: 1), #colorLiteral(red: 1, green: 0.3134631849, blue: 0, alpha: 1), #colorLiteral(red: 1, green: 0, blue: 0, alpha: 1)]
        chartDataSet.setCircleColor(#colorLiteral(red: 0, green: 0.4566611071, blue: 1, alpha: 1))
        chartDataSet.circleHoleColor = #colorLiteral(red: 0, green: 0.4616597415, blue: 1, alpha: 1)
        chartDataSet.circleHoleRadius = 1
        chartDataSet.circleRadius = 5
        chartDataSet.mode = .cubicBezier
        chartDataSet.cubicIntensity = 0.15
        chartDataSet.drawCirclesEnabled = true
        
        let gradientColours = [UIColor.systemPink.cgColor, UIColor.clear.cgColor] as CFArray
        let colourLocations : [CGFloat] = [1.0, 0.0] // position of gradient
        guard let gradient = CGGradient.init(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: gradientColours, locations: colourLocations) else {
            print("gradient error")
            return
        }
        //chartDataSet.fill = Fill.fillWithLinearGradient(gradient, angle: 90.0)
        chartDataSet.fill = Fill.fillWithColor(#colorLiteral(red: 0, green: 0.4616597415, blue: 1, alpha: 1))
        chartDataSet.drawFilledEnabled = true
        
        
        lineChartView.xAxis.drawGridLinesEnabled = false
        lineChartView.chartDescription?.enabled = false
        lineChartView.legend.enabled = false
        lineChartView.leftAxis.drawGridLinesEnabled = false
        lineChartView.leftAxis.drawAxisLineEnabled = false
        lineChartView.leftAxis.drawLabelsEnabled = false
        lineChartView.rightAxis.drawLabelsEnabled = false
        lineChartView.rightAxis.drawGridLinesEnabled = false
        lineChartView.xAxis.drawLabelsEnabled = false
        
        lineChartView.data = chartData
        
    }
    
}
