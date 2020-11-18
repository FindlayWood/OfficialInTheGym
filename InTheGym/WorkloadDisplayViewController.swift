//
//  WorkloadDisplayViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 16/11/2020.
//  Copyright © 2020 FindlayWood. All rights reserved.
//

import UIKit
import Firebase

protocol GetChartData {
    func getChartData(with dataPoints: [Int], values: [Int], size: Int)
    var workoutLoad: [Int] {get set}
    var dates: [Int] {get set}
    var size: Int {get set}
}

class WorkloadDisplayViewController: UIViewController, GetChartData {
    
    @IBOutlet var segment:UISegmentedControl!
    @IBOutlet var workloadLabel:UILabel!
    @IBOutlet var workoutLabel:UILabel!
    @IBOutlet var timeLabel:UILabel!
    @IBOutlet var rpeLabel:UILabel!
    @IBOutlet var chartLabel:UILabel!
    
    @IBOutlet var oneView:UIView!
    @IBOutlet var twoView:UIView!
    @IBOutlet var threeView:UIView!
    @IBOutlet var fourViews:UIView!
    
    // variables to display
    var globalWorkload : Int = 0
    var globalTime : Int = 0
    var globalRPE : Int = 0
    var globalCount : Int = 0
    
    // 3 day arrays
    var threeWorkloadArray : [Int] = []
    var threeTimeArray : [Int] = []
    var threeRPEArray : [Int] = []
    var threeEndDates : [Date] = []
    
    // 7 day arrays
    var sevenWorkloadArray : [Int] = []
    var sevenTimeArray : [Int] = []
    var sevenRPEArray : [Int] = []
    var sevenEndDates : [Date] = []
    
    // 14 day arrays
    var twoWeekWorkloadArray : [Int] = []
    var twoWeekTimeArray : [Int] = []
    var twoWeekRPEArray : [Int] = []
    var twoWeekEndDates : [Date] = []
    
    // 28 day arrays
    var fourWeekWorkloadArray : [Int] = []
    var fourWeekTimeArray : [Int] = []
    var fourWeekRPEArray : [Int] = []
    var fourWeekEndDates : [Date] = []

    
    // variables for time frames
    let threeDaysAgo = Calendar.current.date(byAdding: .day, value: -3, to: Date())
    let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())
    let twoWeeksAgo = Calendar.current.date(byAdding: .day, value: -14, to: Date())
    let fourWeeksAgo = Calendar.current.date(byAdding: .day, value: -28, to: Date())
    
    
    // username of player passed from previous page
    var username : String!
    
    // database reference
    var DBRef : DatabaseReference!
    
    // arrays to populate the linechart
    var workoutLoad = [Int]()
    var dates = [Int]()
    var size = Int()
    
    // outlet to line view
    @IBOutlet var lineView:UIView!
    
    // array to hold dates number for line chart
    var chartDays : [Int] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        DBRef = Database.database().reference().child("Workloads").child(username)
        
        setupViews()
        
        
        // added for new feed
        segment.addTarget(self, action: #selector(handleSegmentChange), for: .valueChanged)
        let NotSelectedTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 12)]
        let SelectedTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 12)]
        segment.setTitleTextAttributes(NotSelectedTextAttributes, for: .normal)
        segment.setTitleTextAttributes(SelectedTextAttributes, for: .selected)
        
    }
    
    @objc fileprivate func handleSegmentChange(){
        
        globalWorkload = 0
        globalTime = 0
        globalRPE = 0
        globalCount = 0
        chartDays.removeAll()
        
        switch segment.selectedSegmentIndex{
        case 0:
            threeSetUp()
            chartLabel.text = "3d ago"
        case 1:
            sevenSetUp()
            chartLabel.text = "7d ago"
        case 2:
            twoWeekSetUp()
            chartLabel.text = "14d ago"
        case 3:
            fourWeekSetUp()
            chartLabel.text = "2w ago"
        default:
            threeSetUp()
            chartLabel.text = "4w ago"
        }
        //setLabels()
    }

    func setupViews(){
        let theViews = [oneView, twoView, threeView, fourViews]
        for myView in theViews{
            myView?.layer.cornerRadius = 10
            myView?.layer.borderWidth = 2.0
            myView?.layer.borderColor = UIColor.black.cgColor
        }
    }
    
    func loadNumbers(){
        
        let now = Date()
        let threeDayRange = threeDaysAgo!...now
        let sevenDayRange = sevenDaysAgo!...now
        let twoWeekRange = twoWeeksAgo!...now
        let fourWeekRange = fourWeeksAgo!...now
        
        DBRef.observe(.childAdded, with: { (snapshot) in
            if let snap = snapshot.value as? [String: AnyObject]{
                let time = snap["endTime"] as! TimeInterval
                let endDate = Date(timeIntervalSinceReferenceDate: time)
                let workload = snap["workload"] as! Int
                let timeToComplete = snap["timeToComplete"] as! Int
                let rpe = snap["rpe"] as! String
                
                if threeDayRange.contains(endDate){
                    self.threeWorkloadArray.append(workload)
                    self.threeTimeArray.append(timeToComplete)
                    self.threeRPEArray.append(Int(rpe)!)
                    self.threeEndDates.append(endDate)
                    self.threeSetUp()
                }
                if sevenDayRange.contains(endDate){
                    self.sevenWorkloadArray.append(workload)
                    self.sevenTimeArray.append(timeToComplete)
                    self.sevenRPEArray.append(Int(rpe)!)
                    self.sevenEndDates.append(endDate)
                }
                if twoWeekRange.contains(endDate){
                    self.twoWeekWorkloadArray.append(workload)
                    self.twoWeekTimeArray.append(timeToComplete)
                    self.twoWeekRPEArray.append(Int(rpe)!)
                    self.twoWeekEndDates.append(endDate)
                }
                if fourWeekRange.contains(endDate){
                    self.fourWeekWorkloadArray.append(workload)
                    self.fourWeekTimeArray.append(timeToComplete)
                    self.fourWeekRPEArray.append(Int(rpe)!)
                    self.fourWeekEndDates.append(endDate)
                }
            }
        }, withCancel: nil)
        //threeSetUp()
    }
    
    func threeSetUp(){
        for i in 0..<threeWorkloadArray.count{
            globalWorkload += threeWorkloadArray[i]
            globalTime += threeTimeArray[i]
            globalRPE += threeRPEArray[i]
            let diffInDays = Calendar.current.dateComponents([.day], from: threeEndDates[i], to: Date())
            chartDays.append(3 - diffInDays.day!)
        }
        globalCount += threeWorkloadArray.count
        setLabels()
        print(chartDays)
        populateChart(with: chartDays, and: threeWorkloadArray, withSize: 3)
        lineChart()
    }
    
    func sevenSetUp(){
        for i in 0..<sevenWorkloadArray.count{
            globalWorkload += sevenWorkloadArray[i]
            globalTime += sevenTimeArray[i]
            globalRPE += sevenRPEArray[i]
            let diffInDays = Calendar.current.dateComponents([.day], from: sevenEndDates[i], to: Date())
            chartDays.append(7 - diffInDays.day!)
        }
        globalCount += sevenWorkloadArray.count
        setLabels()
        populateChart(with: chartDays, and: sevenWorkloadArray, withSize: 7)
        lineChart()
    }
    
    func twoWeekSetUp(){
        for i in 0..<twoWeekWorkloadArray.count{
            globalWorkload += twoWeekWorkloadArray[i]
            globalTime += twoWeekTimeArray[i]
            globalRPE += twoWeekRPEArray[i]
            let diffInDays = Calendar.current.dateComponents([.day], from: twoWeekEndDates[i], to: Date())
            chartDays.append(14 - diffInDays.day!)
        }
        globalCount += twoWeekWorkloadArray.count
        setLabels()
        populateChart(with: chartDays, and: twoWeekWorkloadArray, withSize: 14)
        lineChart()
    }
    
    func fourWeekSetUp(){
        for i in 0..<fourWeekWorkloadArray.count{
            globalWorkload += fourWeekWorkloadArray[i]
            globalTime += fourWeekTimeArray[i]
            globalRPE += fourWeekRPEArray[i]
            let diffInDays = Calendar.current.dateComponents([.day], from: fourWeekEndDates[i], to: Date())
            chartDays.append(28 - diffInDays.day!)
        }
        globalCount += fourWeekWorkloadArray.count
        setLabels()
        populateChart(with: chartDays, and: fourWeekWorkloadArray, withSize: 28)
        lineChart()
        
    }
    
    func setLabels(){
        
        let formatter = DateComponentsFormatter()
        
        if globalTime > 3600{
            formatter.allowedUnits = [.hour, .minute]
            formatter.unitsStyle = .abbreviated
        }else{
            formatter.allowedUnits = [.minute, .second]
            formatter.unitsStyle = .abbreviated
        }
        
        let timeString = formatter.string(from: TimeInterval(globalTime))
        
        workloadLabel.text = globalWorkload.description
        timeLabel.text = timeString
        if globalRPE == 0{
            rpeLabel.text = "0"
        }else{
            rpeLabel.text = "\(Double(globalRPE) / Double(globalCount))"
        }
        workoutLabel.text = globalCount.description
    }
    
    
    func populateChart(with workArray: [Int], and dateArray: [Int], withSize size: Int){
        self.workoutLoad  = workArray
        self.dates = dateArray
        self.size = size
        getChartData(with: workoutLoad, values: dates, size: self.size)
       }
       
    func getChartData(with dataPoints: [Int], values: [Int], size: Int) {
        self.workoutLoad = dataPoints
        self.dates = values
        self.size = size
    }
       
    func lineChart(){
        let lineChart = LineChart(frame: CGRect(x: 0.0, y: 0.0, width: self.lineView.frame.width, height: self.lineView.frame.height))
        lineChart.delegate = self
        lineView.addSubview(lineChart)
           
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadNumbers()
        segment.selectedSegmentIndex = 0
        segment.sendActions(for: UIControl.Event.valueChanged)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        let textAttributes = [NSAttributedString.Key.foregroundColor:#colorLiteral(red: 0, green: 0.4618991017, blue: 1, alpha: 1)]
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 0, green: 0.4618991017, blue: 1, alpha: 1)
    }

}
