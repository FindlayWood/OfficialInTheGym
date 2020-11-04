//
//  MyInfoViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 29/07/2019.
//  Copyright © 2019 FindlayWood. All rights reserved.
//

import UIKit
import Firebase
import Charts

class MyInfoViewController: UIViewController {
    
    @IBOutlet weak var nameLabel:UILabel!
    @IBOutlet weak var usernameLabel:UILabel!
    @IBOutlet weak var emailLabel:UILabel!
    @IBOutlet weak var playerCountLabel:UILabel!
    @IBOutlet weak var workoutsSetCount:UILabel!
    
    @IBOutlet weak var pieChartView:PieChartView!
    
    
    var firstDataEntry = PieChartDataEntry(value: 0)
    var secondDataEntry = PieChartDataEntry(value: 0)
    
    
    var numberOfScores = [PieChartDataEntry]()
    
    var DBRef:DatabaseReference!
    var ScoreRef:DatabaseReference!
    var playerCount:Int!
    
    var score:[[String:AnyObject]] = []
    var scores:[Int] = []
    var counter:[String:Int] = [:]
    

    override func viewDidLoad() {
        super.viewDidLoad()
        let userID = Auth.auth().currentUser?.uid
        DBRef = Database.database().reference().child("users").child(userID!)
        ScoreRef = Database.database().reference().child("Scores").child(AdminActivityViewController.username)
        

    }
    
    func loadInfo(){
        DBRef.observe(.value) { (snapshot) in
            if let snap = snapshot.value as? [String:AnyObject]{
                let first = snap["firstName"] as? String ?? "First"
                let last = snap["lastName"] as? String ?? "Last"
                self.nameLabel.text = "\(first) \(last)"
                let username = snap["username"] as? String
                self.usernameLabel.text = "@\(username!)"
                self.emailLabel.text = snap["email"] as? String
            }
        }
    }
    
    func loadNumberOfUsers(){
        DBRef.child("players").child("accepted").observeSingleEvent(of: .value) { (snapshot) in
            if let snap = snapshot.value as? [String]{
                self.playerCount = snap.count
                self.playerCountLabel.text = "\(self.playerCount!)"
            }
        }
    }
    
    func loadNumberOfWorkouts(){
        DBRef.child("NumberOfWorkouts").observeSingleEvent(of: .value) { (snapshot) in
            let count = snapshot.value as? Int
            self.workoutsSetCount.text = "\(count ?? 0)"
        }
    }
    
    func loadScores(){
        var numberPlease: Int!
        score.removeAll()
        ScoreRef.observe(.value) { (snapshot) in
            numberPlease = Int(snapshot.childrenCount)
            var x = 0
            self.ScoreRef.observe(.childAdded, with: { (snapshot) in
                if let snap = snapshot.value as? [String:AnyObject]{
                    self.score.append(snap)
                    if x < (numberPlease-1){
                        x += 1
                    }
                    else{
                        self.printValues()
                    }
                }
            }, withCancel: nil)
        }
        
    }
    
    func printValues(){
        scores.removeAll()
        for x in score{
            for (_, value) in x{
                let sval = value as! String
                let ival = Int(sval)
                scores.append(ival!)
            }
        }
        countOccur()
    }
    
    func countOccur(){
        counter.removeAll()
        for item in scores{
            counter[String(item)] = (counter[String(item)] ?? 0) + 1
        }
        setChartData()
        calcAverage()
    }
    
    func calcAverage(){
        var total = 0.0
        for num in scores{
            total += Double(num)
        }
        let average = String(round(total/Double(scores.count)*10)/10)
        let myAttribute = [NSAttributedString.Key.font: UIFont(name: "Menlo-Bold", size: 20)!]
        let myAttrString = NSAttributedString(string: average, attributes: myAttribute)
        pieChartView.centerAttributedText = myAttrString
    }
    
    func setChartData(){
        let zeroEntry = PieChartDataEntry(value: Double(counter["0"] ?? 0))
        zeroEntry.label = "0"
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
        
        
        
        numberOfScores = [zeroEntry,oneEntry,twoEntry,threeEntry,fourEntry,fiveEntry,sixEntry,sevenEntry,eightEntry,nineEntry,tenEntry]
        
        
        
        updateChartData()
        
        
    }
    
    func updateChartData(){
        let chartDataSet = PieChartDataSet(entries: numberOfScores, label: nil)
        
        let noZeroFormatter = NumberFormatter()
        noZeroFormatter.zeroSymbol = ""
        chartDataSet.valueFormatter = DefaultValueFormatter(formatter: noZeroFormatter)
        
        let chartData = PieChartData(dataSet: chartDataSet)
        
        let colors = [#colorLiteral(red: 0.3021106021, green: 0.4654112241, blue: 1, alpha: 0.3329141695), #colorLiteral(red: 0.3021106021, green: 0.4654112241, blue: 1, alpha: 0.549604024), #colorLiteral(red: 0.3021106021, green: 0.4654112241, blue: 1, alpha: 0.7467893836), #colorLiteral(red: 0.3021106021, green: 0.4654112241, blue: 1, alpha: 0.8184931507), #colorLiteral(red: 0.3021106021, green: 0.4654112241, blue: 1, alpha: 0.9183433219), #colorLiteral(red: 0.004983612501, green: 0.1452928051, blue: 0.7435358503, alpha: 1), #colorLiteral(red: 0.004527620861, green: 0.131998773, blue: 0.6755036485, alpha: 1), #colorLiteral(red: 0.003697771897, green: 0.107805262, blue: 0.5516933693, alpha: 1),#colorLiteral(red: 0.003351292677, green: 0.09770396748, blue: 0.5, alpha: 1), #colorLiteral(red: 0.00270232527, green: 0.07878389795, blue: 0.4031765546, alpha: 1), #colorLiteral(red: 0.00198916551, green: 0.05799235728, blue: 0.2967758566, alpha: 1)]
        chartDataSet.colors = colors
        chartDataSet.drawValuesEnabled = true
        chartDataSet.valueFont = UIFont(name: "Menlo-Bold", size: 20)!
        pieChartView.drawEntryLabelsEnabled = false
        
        pieChartView.data = chartData
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadInfo()
        loadNumberOfUsers()
        loadNumberOfWorkouts()
        loadScores()
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    

}
