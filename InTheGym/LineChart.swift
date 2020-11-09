//
//  LineChart.swift
//  InTheGym
//
//  Created by Findlay Wood on 08/11/2020.
//  Copyright © 2020 FindlayWood. All rights reserved.
//

import Foundation
import Charts

class LineChart: UIView, ChartViewDelegate {
    
    let lineChartView = LineChartView()
    var lineDataEntry : [ChartDataEntry] = []
    
    var workoutDuration = [String]()
    var beatsPerMinute = [String]()
    
    var delegate : GetChartData! {
        didSet{
            populateData()
            lineChartSetup()
        }
    }
    
    func populateData(){
        self.workoutDuration = delegate.workoutDuration
        self.beatsPerMinute = delegate.beatsPerMinutes
    }
    
    
//    func calcValues(){
//        scores.removeAll()
//        for x in score{
//            for (_, value) in x{
//                let sval = value as! String
//                let ival = Int(sval)
//                scores.append(ival!)
//            }
//        }
//        countOccur()
//        //calcAverage()
//    }
//
//    func countOccur(){
//        counter.removeAll()
//        for item in scores{
//            counter[String(item)] = (counter[String(item)] ?? 0) + 1
//        }
//        lineChartSetup()
//    }
    
//    func calcAverage(){
//        var total = 0.0
//        for num in scores{
//            total += Double(num)
//        }
//        let average = String(round(total/Double(scores.count)*10)/10)
//        let myAttribute = [NSAttributedString.Key.font: UIFont(name: "Menlo-Bold", size: 15)!]
//        let myAttrString = NSAttributedString(string: average, attributes: myAttribute)
//        pieChart.centerAttributedText = myAttrString
//    }
    
    func lineChartSetup(){
        self.backgroundColor = .white
        self.addSubview(lineChartView)
        lineChartView.translatesAutoresizingMaskIntoConstraints = false
        lineChartView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        lineChartView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        lineChartView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        lineChartView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        lineChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption: .easeInOutSine)
        
        setChartData(dataPoints: workoutDuration, values: beatsPerMinute)
    }
    
    func setChartData(dataPoints: [String], values: [String]){
        
        lineChartView.noDataTextColor = .black
        lineChartView.noDataText = "NO DATA"
        lineChartView.backgroundColor = .white
        
        for i in 0..<dataPoints.count{
            let datapoint = ChartDataEntry(x: Double(i), y: Double(values[i])!)
            lineDataEntry.append(datapoint)
        }
        
        let chartDataSet = LineChartDataSet(entries: lineDataEntry, label: "RPE")
        let chartData = LineChartData()
        chartData.addDataSet(chartDataSet)
        chartData.setDrawValues(true)
        chartDataSet.colors = [#colorLiteral(red: 0, green: 0.5, blue: 1, alpha: 1), #colorLiteral(red: 0.6332940925, green: 0.8493953339, blue: 1, alpha: 1), #colorLiteral(red: 0.7802333048, green: 1, blue: 0.5992883134, alpha: 1), #colorLiteral(red: 0.9427440068, green: 1, blue: 0.3910798373, alpha: 1), #colorLiteral(red: 1, green: 1, blue: 0, alpha: 1), #colorLiteral(red: 1, green: 0.8438837757, blue: 0, alpha: 1), #colorLiteral(red: 1, green: 0.7074058219, blue: 0, alpha: 1), #colorLiteral(red: 1, green: 0.4706228596, blue: 0, alpha: 1), #colorLiteral(red: 1, green: 0.3134631849, blue: 0, alpha: 1), #colorLiteral(red: 1, green: 0, blue: 0, alpha: 1)]
        chartDataSet.setCircleColor(UIColor.systemPink)
        chartDataSet.circleHoleColor = UIColor.systemPink
        chartDataSet.circleHoleRadius = 4
        chartDataSet.mode = .cubicBezier
        chartDataSet.cubicIntensity = 0.2
        chartDataSet.drawCirclesEnabled = false
        
        let gradientColours = [UIColor.systemPink.cgColor, UIColor.clear.cgColor] as CFArray
        let colourLocations : [CGFloat] = [1.0, 0.0] // position of gradient
        guard let gradient = CGGradient.init(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: gradientColours, locations: colourLocations) else {
            print("gradient error")
            return
        }
        chartDataSet.fill = Fill.fillWithLinearGradient(gradient, angle: 90.0)
        chartDataSet.drawFilledEnabled = true
        
        
        lineChartView.xAxis.drawGridLinesEnabled = false
        lineChartView.chartDescription?.enabled = false
        lineChartView.legend.enabled = true
        lineChartView.leftAxis.drawGridLinesEnabled = false
        lineChartView.leftAxis.drawLabelsEnabled = true
        
        lineChartView.data = chartData
        
        
    }
    
}
