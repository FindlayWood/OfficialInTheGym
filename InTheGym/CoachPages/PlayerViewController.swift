//
//  PlayerViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 04/07/2019.
//  Copyright © 2019 FindlayWood. All rights reserved.
//

//coaches view of a player

import UIKit
import Charts
import Firebase
import Flurry_iOS_SDK

protocol GetChartData {
    func getChartData(with dataPoints: [String], values: [String])
    var workoutDuration: [String] {get set}
    var beatsPerMinutes: [String] {get set}
}

class PlayerViewController: UIViewController, GetChartData {
    
    // outlet variables for user info
    @IBOutlet weak var userName:UILabel!
    @IBOutlet weak var userEmail:UILabel!
    @IBOutlet weak var firstName:UILabel!
    @IBOutlet weak var lastName:UILabel!
    // string variables for user info
    var userNameString:String = ""
    var userEmailString:String = ""
    var firstNameString:String = ""
    var lastNameString:String = ""
    
    // outlets for last 3 scores
    @IBOutlet weak var firstScore:UILabel!
    @IBOutlet weak var secondScore:UILabel!
    @IBOutlet weak var thirdScore:UILabel!
    // array of rpe colours
    let colours = [#colorLiteral(red: 0, green: 0.5, blue: 1, alpha: 1), #colorLiteral(red: 0.6332940925, green: 0.8493953339, blue: 1, alpha: 1), #colorLiteral(red: 0.7802333048, green: 1, blue: 0.5992883134, alpha: 1), #colorLiteral(red: 0.9427440068, green: 1, blue: 0.3910798373, alpha: 1), #colorLiteral(red: 1, green: 1, blue: 0, alpha: 1), #colorLiteral(red: 1, green: 0.8438837757, blue: 0, alpha: 1), #colorLiteral(red: 1, green: 0.7074058219, blue: 0, alpha: 1), #colorLiteral(red: 1, green: 0.4706228596, blue: 0, alpha: 1), #colorLiteral(red: 1, green: 0.3134631849, blue: 0, alpha: 1), #colorLiteral(red: 1, green: 0, blue: 0, alpha: 1)]
    
    // outlet view for pie chart of scores
    @IBOutlet weak var pieChart:PieChartView!
    
    // arrays for scores and counter of workouts
    var score:[[String:AnyObject]] = []
    var scores:[Int] = []
    var counter:[String:Int] = [:]
    
    //database reference
    var DBRef:DatabaseReference!
    
    // data of scores for piechart
    var numberOfScores = [PieChartDataEntry]()
    
    // outlet to view behind last three workouts & behind each number
    @IBOutlet weak var behind:UIView!
    @IBOutlet weak var firstView:UIView!
    @IBOutlet weak var secondView:UIView!
    @IBOutlet weak var thirdView:UIView!
    
    // outlet to top view behind user info and its height
    @IBOutlet weak var topView:UIView!
    
    @IBOutlet var topViewHeight: NSLayoutConstraint!
    
    // outlet to line view
    @IBOutlet var lineView:UIView!
    
    var workoutDuration = [String]()
    var beatsPerMinutes = [String]()
    
    
    //function for when the user taps add workout
    @IBAction func addWorkoutPressed(_ sender:UIButton){
        Flurry.logEvent("Coaches Player view - Add Workouts.")
        sender.pulsate()
        let StoryBoard = UIStoryboard(name: "Main", bundle: nil)
        let SVC = StoryBoard.instantiateViewController(withIdentifier: "AddWorkoutHomeViewController") as! AddWorkoutHomeViewController
        SVC.userName = self.userNameString
        AddWorkoutHomeViewController.groupBool = false
        self.navigationController?.pushViewController(SVC, animated: true)
    }
    
    //function for when the user taps view pbs
    @IBAction func viewPBsPressed(_ sender:UIButton){
        Flurry.logEvent("Coaches Player view - View PBs.")
        sender.pulsate()
        let StoryBoard = UIStoryboard(name: "Main", bundle: nil)
        let SVC = StoryBoard.instantiateViewController(withIdentifier: "PBsViewController") as! PBsViewController
        SVC.username = self.userNameString
        self.navigationController?.pushViewController(SVC, animated: true)
    }
    
    //function for when the user taps view workouts
    @IBAction func viewWorkoutsPressed(_ sender:UIButton){
        Flurry.logEvent("Coaches Player view - View Workouts.")
        sender.pulsate()
        let StoryBoard = UIStoryboard(name: "Main", bundle: nil)
        let SVC = StoryBoard.instantiateViewController(withIdentifier: "ViewWorkoutViewController") as! ViewWorkoutViewController
        SVC.username = self.userNameString
        self.navigationController?.pushViewController(SVC, animated: true)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        userName.text = "Username: \(userNameString)"
        userEmail.text = "Email: \(userEmailString)"
        firstName.text = "First Name: \(firstNameString)"
        lastName.text = "Last Name: \(lastNameString)"
        navigationItem.title = "Player Info"
        
        pieChart.backgroundColor = #colorLiteral(red: 0, green: 0.4618991017, blue: 1, alpha: 1)

        
        DBRef = Database.database().reference().child("Scores").child(userNameString)
        
        let screenSize = view.frame.size
        
        // setup the views
        topViewHeight.constant = screenSize.height/5
        topView.layer.cornerRadius = 20
        behind.layer.cornerRadius = 20
        behind.layer.borderWidth = 2
        behind.layer.borderColor = UIColor.black.cgColor
        firstView.layer.cornerRadius = 25
        secondView.layer.cornerRadius = 25
        thirdView.layer.cornerRadius = 25
        
        pieChart.legend.enabled = false
    }
    
    func loadScores(){
        score.removeAll()
        
        
        self.DBRef.observe(.childAdded, with: { (snapshot) in
            if let snap = snapshot.value as? [String:AnyObject]{
                self.score.append(snap)
                self.calcValues()
            }
        }, withCancel: nil)
    }
    
    func calcValues(){
        scores.removeAll()
        for x in score{
            for (_, value) in x{
                let sval = value as! String
                let ival = Int(sval)
                scores.append(ival!)
            }
        }
        lastThree(array: scores.suffix(3))
        countOccur()
        calcAverage()
    }
    
    func lastThree(array: [Int]){
        switch array.count {
        case 0:
            print("0 items, last score nothing")
        case 1:
            print("1 item, last score is \(array[0])")
            self.firstScore.text = "\(array[0])"
            self.firstView.backgroundColor = colours[array[0]-1]
            self.secondScore.text = ""
            self.thirdScore.text = ""
            
            
        case 2:
            print("2 items, last scores are \(array[1]), \(array[0])")
            self.firstScore.text = "\(array[1])"
            self.firstView.backgroundColor = colours[array[1]-1]
            self.secondScore.text = "\(array[0])"
            self.secondView.backgroundColor = colours[array[0]-1]
            self.thirdScore.text = ""
        case 3:
            print("3 items, last scores are \(array[2]), \(array[1]), \(array[0])")
            self.firstScore.text = "\(array[2])"
            self.firstView.backgroundColor = colours[array[2]-1]
            self.secondScore.text = "\(array[1])"
            self.secondView.backgroundColor = colours[array[1]-1]
            self.thirdScore.text = "\(array[0])"
            self.thirdView.backgroundColor = colours[array[0]-1]
        default:
            print("error")
        }
    }
    
    func countOccur(){
        counter.removeAll()
        for item in scores{
            counter[String(item)] = (counter[String(item)] ?? 0) + 1
        }
        print(counter)
        setChartData()
    }
    
    func calcAverage(){
        var total = 0.0
        for num in scores{
            total += Double(num)
        }
        let average = String(round(total/Double(scores.count)*10)/10)
        let myAttribute = [NSAttributedString.Key.font: UIFont(name: "Menlo-Bold", size: 15)!]
        let myAttrString = NSAttributedString(string: average, attributes: myAttribute)
        pieChart.centerAttributedText = myAttrString
    }
    
    func setChartData(){
//        let zeroEntry = PieChartDataEntry(value: Double(counter["0"] ?? 0))
//        zeroEntry.label = "0"
        let oneEntry = PieChartDataEntry(value: Double(counter["1"] ?? 0))
        oneEntry.label = "1"
        let twoEntry = PieChartDataEntry(value: Double(counter["2"] ?? 0))
        twoEntry.label = "2"
        let threeEntry = PieChartDataEntry(value: Double(counter["3"] ?? 0))
        threeEntry.label = "3"
        let fourEntry = PieChartDataEntry(value: Double(counter["4"] ?? 0))
        fourEntry.label = "4"
        let fiveEntry = PieChartDataEntry(value: Double(counter["5"] ?? 0))
        fiveEntry.label = "5"
        let sixEntry = PieChartDataEntry(value: Double(counter["6"] ?? 0))
        sixEntry.label = "6"
        let sevenEntry = PieChartDataEntry(value: Double(counter["7"] ?? 0))
        sevenEntry.label = "7"
        let eightEntry = PieChartDataEntry(value: Double(counter["8"] ?? 0))
        eightEntry.label = "8"
        let nineEntry = PieChartDataEntry(value: Double(counter["9"] ?? 0))
        nineEntry.label = "9"
        let tenEntry = PieChartDataEntry(value: Double(counter["10"] ?? 0))
        tenEntry.label = "10"
        
        
        
        numberOfScores = [oneEntry,twoEntry,threeEntry,fourEntry,fiveEntry,sixEntry,sevenEntry,eightEntry,nineEntry,tenEntry]
        
        
        
        updateChartData()
        
        
    }
    
    func updateChartData(){
        let chartDataSet = PieChartDataSet(entries: numberOfScores, label: nil)
        
        let noZeroFormatter = NumberFormatter()
        noZeroFormatter.zeroSymbol = ""
        chartDataSet.valueFormatter = DefaultValueFormatter(formatter: noZeroFormatter)
        
        let chartData = PieChartData(dataSet: chartDataSet)
        
        let colors = [#colorLiteral(red: 0, green: 0.5, blue: 1, alpha: 1), #colorLiteral(red: 0.6332940925, green: 0.8493953339, blue: 1, alpha: 1), #colorLiteral(red: 0.7802333048, green: 1, blue: 0.5992883134, alpha: 1), #colorLiteral(red: 0.9427440068, green: 1, blue: 0.3910798373, alpha: 1), #colorLiteral(red: 1, green: 1, blue: 0, alpha: 1), #colorLiteral(red: 1, green: 0.8438837757, blue: 0, alpha: 1), #colorLiteral(red: 1, green: 0.7074058219, blue: 0, alpha: 1), #colorLiteral(red: 1, green: 0.4706228596, blue: 0, alpha: 1), #colorLiteral(red: 1, green: 0.3134631849, blue: 0, alpha: 1), #colorLiteral(red: 1, green: 0, blue: 0, alpha: 1)]
        chartDataSet.colors = colors
        
    
        chartDataSet.drawValuesEnabled = true
        chartDataSet.valueFont = UIFont(name: "Menlo-Bold", size: 15)!
        chartDataSet.valueTextColor = .black
        pieChart.drawEntryLabelsEnabled = false
        
        pieChart.data = chartData
        
        populateChart()
        lineChart()
        
    }
    
    func populateChart(){
        self.workoutDuration  = ["1", "2", "3", "4", "5"]
        self.beatsPerMinutes = ["109","412","333","457","289"]
        getChartData(with: workoutDuration, values: beatsPerMinutes)
    }
    
    func getChartData(with dataPoints: [String], values: [String]) {
        self.workoutDuration = dataPoints
        self.beatsPerMinutes = values
    }
    
    func lineChart(){
        let lineChart = LineChart(frame: CGRect(x: 0.0, y: 0.0, width: self.lineView.frame.width, height: self.lineView.frame.height))
        lineChart.delegate = self
        lineView.addSubview(lineChart)
        
    }
    

    override func viewWillAppear(_ animated: Bool) {
        loadScores()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        let textAttributes = [NSAttributedString.Key.foregroundColor:#colorLiteral(red: 0, green: 0.4618991017, blue: 1, alpha: 1)]
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 0, green: 0.4618991017, blue: 1, alpha: 1)
        
    }

}
