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

class PlayerViewController: UIViewController {
    
    // outlet variables for user info
    @IBOutlet weak var userName:UILabel!
    @IBOutlet weak var userEmail:UILabel!
    @IBOutlet weak var firstName:UILabel!
    @IBOutlet weak var lastName:UILabel!
    @IBOutlet weak var workoutsCompleted:UILabel!
    // string variables for user info
    var userNameString:String = ""
    var userEmailString:String = ""
    var firstNameString:String = ""
    var lastNameString:String = ""
    var workoutsCompletedInt: Int = 0
    
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
    
    @IBOutlet weak var usernameView:UIView!
    @IBOutlet weak var workoutsView:UIView!
    
    // outlet to top view behind user info
    @IBOutlet weak var topView:UIView!
    
    
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
        workoutsCompleted.text = "Workouts Completed: \(workoutsCompletedInt)"
        
        

//        let attachment = NSTextAttachment()
//        attachment.image = UIImage(named: "fire_icon")
//        attachment.bounds = CGRect(x: 0, y: -2.5, width: 20, height: 20)
//        
//        let attachmentString = NSAttributedString(attachment: attachment)
//        let beforeString = NSMutableAttributedString(string: "Workouts Completed: \(workoutsCompletedInt) ")
//        beforeString.append(attachmentString)
//        workoutsCompleted.attributedText = beforeString
        
        
        
        navigationItem.title = "Player Info"
        
        pieChart.backgroundColor = #colorLiteral(red: 0, green: 0.4618991017, blue: 1, alpha: 1)

        
        DBRef = Database.database().reference().child("Scores").child(userNameString)
        
        // setup the views
        topView.layer.cornerRadius = 20
        behind.layer.cornerRadius = 20
        firstView.layer.cornerRadius = 25
        secondView.layer.cornerRadius = 25
        thirdView.layer.cornerRadius = 25
        //usernameView.layer.cornerRadius = 20
        //workoutsView.layer.cornerRadius = 20
        
        topView.layer.borderWidth = 2.0
        topView.layer.borderColor = UIColor.black.cgColor
        behind.layer.borderWidth = 2.0
        behind.layer.borderColor = UIColor.black.cgColor
//        usernameView.layer.borderWidth = 2.0
//        usernameView.layer.borderColor = UIColor.black.cgColor
//        workoutsView.layer.borderWidth = 2.0
//        workoutsView.layer.borderColor = UIColor.black.cgColor
        
        pieChart.legend.enabled = false
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(sendToWorkload))
        behind.addGestureRecognizer(gesture)
    }
    
    @objc fileprivate func sendToWorkload(){
        let StoryBoard = UIStoryboard(name: "Main", bundle: nil)
        let SVC = StoryBoard.instantiateViewController(withIdentifier: "WorkloadDisplayViewController") as! WorkloadDisplayViewController
        SVC.username = self.userNameString
        self.navigationController?.pushViewController(SVC, animated: true)
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
        
        //let colors = [#colorLiteral(red: 0.3021106021, green: 0.4654112241, blue: 1, alpha: 0.3329141695), #colorLiteral(red: 0.3021106021, green: 0.4654112241, blue: 1, alpha: 0.549604024), #colorLiteral(red: 0.3021106021, green: 0.4654112241, blue: 1, alpha: 0.7467893836), #colorLiteral(red: 0.3021106021, green: 0.4654112241, blue: 1, alpha: 0.8184931507), #colorLiteral(red: 0.3021106021, green: 0.4654112241, blue: 1, alpha: 0.9183433219), #colorLiteral(red: 0.004983612501, green: 0.1452928051, blue: 0.7435358503, alpha: 1), #colorLiteral(red: 0.004527620861, green: 0.131998773, blue: 0.6755036485, alpha: 1), #colorLiteral(red: 0.003697771897, green: 0.107805262, blue: 0.5516933693, alpha: 1),#colorLiteral(red: 0.003351292677, green: 0.09770396748, blue: 0.5, alpha: 1), #colorLiteral(red: 0.00270232527, green: 0.07878389795, blue: 0.4031765546, alpha: 1), #colorLiteral(red: 0.00198916551, green: 0.05799235728, blue: 0.2967758566, alpha: 1)]
        let colors = [#colorLiteral(red: 0, green: 0.5, blue: 1, alpha: 1), #colorLiteral(red: 0.6332940925, green: 0.8493953339, blue: 1, alpha: 1), #colorLiteral(red: 0.7802333048, green: 1, blue: 0.5992883134, alpha: 1), #colorLiteral(red: 0.9427440068, green: 1, blue: 0.3910798373, alpha: 1), #colorLiteral(red: 1, green: 1, blue: 0, alpha: 1), #colorLiteral(red: 1, green: 0.8438837757, blue: 0, alpha: 1), #colorLiteral(red: 1, green: 0.7074058219, blue: 0, alpha: 1), #colorLiteral(red: 1, green: 0.4706228596, blue: 0, alpha: 1), #colorLiteral(red: 1, green: 0.3134631849, blue: 0, alpha: 1), #colorLiteral(red: 1, green: 0, blue: 0, alpha: 1)]
        chartDataSet.colors = colors
        
    
        chartDataSet.drawValuesEnabled = true
        chartDataSet.valueFont = UIFont(name: "Menlo-Bold", size: 15)!
        chartDataSet.valueTextColor = .black
        pieChart.drawEntryLabelsEnabled = false
        
        pieChart.data = chartData
    }
    

    override func viewWillAppear(_ animated: Bool) {
        loadScores()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        let textAttributes = [NSAttributedString.Key.foregroundColor:#colorLiteral(red: 0, green: 0.4618991017, blue: 1, alpha: 1)]
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 0, green: 0.4618991017, blue: 1, alpha: 1)
        
    }

}
