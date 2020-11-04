//
//  PlayerInfoViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 30/07/2019.
//  Copyright © 2019 FindlayWood. All rights reserved.
//

import UIKit
import Firebase
import Charts
import SCLAlertView
import EmptyDataSet_Swift

class PlayerInfoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, EmptyDataSetSource, EmptyDataSetDelegate {
    
    // variables
    var username:String = ""
    var adminKey:String = ""
    var gotArequest:Bool = false
    var requesters = [String]()
    var requestKeys = [String]()
    
    var score:[[String:AnyObject]] = []
    var scores:[Int] = []
    var counter:[String:Int] = [:]
    
    var numberOfScores = [PieChartDataEntry]()
    
    var DBRef:DatabaseReference!
    var ScoreRef:DatabaseReference!
    
    let userID = Auth.auth().currentUser?.uid
    
    @IBOutlet weak var nameLabel:UILabel!
    @IBOutlet weak var usernameLabel:UILabel!
    @IBOutlet weak var emailLabel:UILabel!
    //@IBOutlet weak var coachNameLabel:UILabel!
    //@IBOutlet weak var coachUsernameLabel:UILabel!
    //@IBOutlet weak var coachEmailLabel:UILabel!
    @IBOutlet weak var countedLabel:UILabel!
    @IBOutlet weak var acceptRequestButton:UIButton!
    
    
    // outlet to pie chart
    @IBOutlet weak var pieChart:PieChartView!
    
    // outlet to tableview
    @IBOutlet weak var tableview:UITableView!
    
    // array of coaches, atm just array of strings
    var coaches = [String]()
    
    // array of all coach data
    var coachFullData :[[String:Any]] = []

    
    @IBAction func viewPBs(_ sender:UIButton){
        sender.pulsate()
        let Storyboard = UIStoryboard(name: "Main", bundle: nil)
        let SVC = Storyboard.instantiateViewController(withIdentifier: "PBsViewController") as! PBsViewController
        SVC.username = self.username
        self.navigationController?.pushViewController(SVC, animated: true)
    }
    
    @IBAction func viewRequests(_ sender:UIButton){
        sender.pulsate()
        let Storyboard = UIStoryboard(name: "Main", bundle: nil)
        let SVC = Storyboard.instantiateViewController(withIdentifier: "RequestsViewController") as! RequestsViewController
        SVC.requesters = self.requesters
        SVC.requestKeys = self.requestKeys
        SVC.username = self.username
        self.navigationController?.pushViewController(SVC, animated: true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DBRef = Database.database().reference()
        
        tableview.delegate = self
        tableview.dataSource = self
        tableview.rowHeight = 100
        tableview.backgroundColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)
        tableview.emptyDataSetSource = self
        tableview.emptyDataSetDelegate = self
        tableview.tableFooterView = UIView()
        
        
        
        self.username = PlayerActivityViewController.username
        self.usernameLabel.text = "@\(PlayerActivityViewController.username ?? "@username")"
        //self.acceptRequestButton.isHidden = true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return coachFullData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! PlayerInfoCell
        //cell.coachName.text = "Phil Jackson"
        cell.coachName.text = coachFullData[indexPath.row]["name"] as? String
        cell.coachUsername.text = coachFullData[indexPath.row]["username"] as? String
        cell.coachEmail.text = coachFullData[indexPath.row]["email"] as? String
        cell.backgroundColor = #colorLiteral(red: 0.9364961361, green: 0.9364961361, blue: 0.9364961361, alpha: 1)
        cell.layer.cornerRadius = 8
        cell.layer.borderWidth = 0
        cell.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let screenSize: CGRect = UIScreen.main.bounds
        let screenWidth = screenSize.width
        
        let appearance = SCLAlertView.SCLAppearance(
            kWindowWidth: screenWidth - 40, showCircularIcon: false
        )
// TODO: add delete coach function on button below
        let alert = SCLAlertView(appearance: appearance)
        alert.addButton("Delete Coach") {
            print("deleting \(self.coachFullData[indexPath.row]["username"] ?? "COACH")...")
        }
        alert.showError("Coach", subTitle: "\(coachFullData[indexPath.row]["username"] ?? "COACH") is one of your coaches. They can view all your workouts and create new ones. You can remove them if you like below.", closeButtonTitle: "Cancel")
    }
    
    // header for tableview
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 50))
        

        let infoButton = UIButton(frame: CGRect(x: 105, y: 5, width: headerView.frame.height-10, height: headerView.frame.height-10))
        infoButton.setImage(#imageLiteral(resourceName: "help-button"), for: .normal)
        infoButton.addTarget(self, action: #selector(showCoachMessage), for: .touchUpInside)
        

        let label = UILabel()
        label.frame = CGRect.init(x: 5, y: 5, width: headerView.frame.width-10, height: headerView.frame.height-10)
        label.text = "Coaches"
        label.font = UIFont(name: "menlo", size: 25) // my custom font
        label.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1) // my custom colour

        headerView.addSubview(label)
        headerView.addSubview(infoButton)
        headerView.backgroundColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)

        return headerView
    }

// TODO: make this alert delete a coach from a player
    @objc func showCoachMessage(){
        let screenSize: CGRect = UIScreen.main.bounds
        let screenWidth = screenSize.width
        
        let appearance = SCLAlertView.SCLAppearance(
            kWindowWidth: screenWidth - 40, showCircularIcon: false
        )
        let alert = SCLAlertView(appearance: appearance)
        alert.showInfo("Your Coaches", subTitle: "Below is a table of all the coaches you have accepted requests from. All these coaches can view all of your workouts and set you workouts. They can also view your activity and PBs. If you want to remove a coach you can do so by tapping on them in the table below.", closeButtonTitle: "Got It!")
    }
    
    func loadCoaches(){
        coaches.removeAll()
        coachFullData.removeAll()
        DBRef.child("users").child(userID!).child("coaches").observe(.childAdded) { (snapshot) in
            if let snap = snapshot.value as? String{
                self.coaches.append(snap)
                self.DBRef.child("users").child(snap).observe(.value) { (snapshot) in
                    if let snap = snapshot.value as? [String:Any]{
                        let username = snap["username"] as? String
                        let email = snap["email"] as? String
                        let first = snap["firstName"] as? String
                        let last = snap["lastName"] as? String
                        let coachData = ["name": first! + " " + last!,
                                         "username": username!,
                                         "email": email!
                        ]
                        self.coachFullData.append(coachData)
                        self.tableview.reloadData()
                    }
                }
                //self.loadScores()
                
            }
            self.loadScores()
        }
    }
    
    
    func requests(){
        self.requesters.removeAll()
        self.requestKeys.removeAll()
        var requestCount = 0
        self.DBRef.child("users").observe(.childAdded, with: { (snapshot) in
            if let snap = snapshot.value as? [String:Any]{
                if snap["admin"] as! Bool == true{
                    if let playerSnap = snap["players"] as? [String:Any]{
                        if let requests = playerSnap["requested"] as? [String]{
                            if requests.contains(self.username){
                                requestCount = requestCount + 1
                                let coach = snap["username"] as! String
                                self.requesters.append(coach)
                                self.requestKeys.append(snapshot.key)
                                //self.adminLabel.text = "you have \(requestCount) new requests"
                                //self.acceptRequestButton.isHidden = false
                            }
                            else{
                                //self.adminLabel.text = "You don't have any new requests."
                               //self.acceptRequestButton.isHidden = true
                            }
                        }
                        else{
                            //self.adminLabel.text = "You don't have any new requests."
                            //self.acceptRequestButton.isHidden = true
                        }
                    }
                }
            }
        }, withCancel: nil)
    }
    
    func loadUserInfo(){
        var coachName:String!
        self.DBRef.child("users").child(userID!).observe(.value) { (snapshot) in
            if let snap = snapshot.value as? [String:Any]{
                let first = snap["firstName"] as? String ?? "FIRST"
                let last = snap["lastName"] as? String ?? "LAST"
                self.nameLabel.text = "\(first) \(last)"
                self.emailLabel.text = snap["email"] as? String
                let counted = snap["numberOfCompletes"] as? Int
                self.countedLabel.text = "\(counted ?? 0)"
                coachName = snap["coachName"] as? String ?? ""
                //self.coachUsernameLabel.text = "@\(coachName!)"
            }
        }
        
        // needs edit. cant use .contain
        
        self.DBRef.child("users").observe(.childAdded, with: { (snapshot) in
            if let snap = snapshot.value as? [String:Any]{
                let x = snap["username"] as! String
                // editing below line from x.contains(coachName) to x == coachName
                // worked fine and fixed error
                if (x == coachName){
                    self.adminKey = snapshot.key
                    self.DBRef.child("users").child(self.adminKey).observe(.value, with: { (snapshot) in
                        if let snap = snapshot.value as? [String:Any]{
                            let first = snap["firstName"] as? String ?? "First"
                            let last = snap["lastName"] as? String ?? "Last"
                            //self.coachNameLabel.text = "\(first) \(last)"
                            let username = snap["username"] as? String
                            //self.coachUsernameLabel.text = "@\(username ?? "")"
                            //self.coachEmailLabel.text = snap["email"] as? String
                        }
                    }, withCancel: nil)
                }
            }
        }, withCancel: nil)
        
    }
    
    func loadScores(){
        score.removeAll()
        for coach in coaches{
            print(coach)
        }
        if ScoreRef != nil {
            ScoreRef.observe(.value) { (snapshot) in
                self.ScoreRef.observe(.value, with: { (snapshot) in
                    if let snap = snapshot.value as? [String:AnyObject]{
                        self.score.append(snap)
                        self.calcValues()
                    }
                }, withCancel: nil)
            }
        }
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
        countOccur()
        calcAverage()
    }
    
    func countOccur(){
        counter.removeAll()
        for item in scores{
            counter[String(item)] = (counter[String(item)] ?? 0) + 1
        }
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
        chartDataSet.valueFont = UIFont(name: "Menlo-Bold", size: 15)!
        pieChart.drawEntryLabelsEnabled = false
        
        pieChart.data = chartData
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if PlayerActivityViewController.coachName != nil {
            ScoreRef = Database.database().reference().child("Scores").child(PlayerActivityViewController.coachName).child(username)
        }
        loadCoaches()
        loadUserInfo()
        requests()
        //loadScores()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }


}
