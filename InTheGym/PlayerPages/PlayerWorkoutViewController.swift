//
//  PlayerWorkoutViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 30/07/2019.
//  Copyright © 2019 FindlayWood. All rights reserved.
//

//***player page***

import UIKit
import Firebase
import SCLAlertView

class PlayerWorkoutViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableview:UITableView!
    
    var workouts:[[String:AnyObject]] = []
    var DBref:DatabaseReference!
    var UsernameRef:DatabaseReference!
    var username:String = ""
    
    //array for workoutIDs, not sure this is needed? maybe it is. i forgot to copy to coach side
    //it is needed!
    var workoutIDs = [String]()
    
    // varibale to check for first time
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    // keep gaps between cells
    var headerHeight: CGFloat = 10.0

    // varibale to store last index of where user was
    static var lastIndex : IndexPath?
    var myGroup = DispatchGroup()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableview.rowHeight = 130
        self.tableview.backgroundColor = #colorLiteral(red: 0, green: 0.4616597415, blue: 1, alpha: 0.5)
        
        let userID = Auth.auth().currentUser?.uid
        
        UsernameRef = Database.database().reference().child("users").child(userID!).child("username")
        DBref = Database.database().reference().child("Workouts")
        
    }
    
    func loadWorkouts(){
        workouts.removeAll()
        DBref.child(PlayerActivityViewController.username).observe(.childAdded, with: { (snapshot) in
            if let snap = snapshot.value as? [String:AnyObject]{
                self.workouts.insert(snap, at: 0)
                self.tableview.reloadData()

            }
        }, withCancel: nil)
        
        DBref.child(PlayerActivityViewController.username).observe(.value) { (snapshot) in
            for snap in snapshot.children{
                let userSnap = snap as! DataSnapshot
                self.workoutIDs.insert(userSnap.key, at: 0)
            }
        }
    }
    
    func loadUsername(){
        UsernameRef.observeSingleEvent(of: .value) { (snapshot) in
            let snap = snapshot.value as! String
            self.username = snap
            //self.loadWorkouts()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableview.dequeueReusableCell(withIdentifier: "cell") as! TableViewCell
        let score = self.workouts[indexPath.section]["score"] as? String
        let startTime = self.workouts[indexPath.section]["startTime"] as? Double
        let timeToComplete = self.workouts[indexPath.section]["timeToComplete"] as? Int
        cell.main.text = self.workouts[indexPath.section]["title"] as? String
        if self.workouts[indexPath.section]["completed"] as! Bool == true{
            cell.second.textColor = #colorLiteral(red: 0.00234289733, green: 0.8251151509, blue: 0.003635218529, alpha: 1)
            cell.second.text = "COMPLETED"
            cell.score.text = "Score: \(score!)"
        }else if startTime != nil && timeToComplete == nil{
            cell.second.textColor = #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1)
            cell.second.text = "IN PROGRESS"
            cell.score.text = ""
            PlayerWorkoutViewController.lastIndex = indexPath
        }else{
            cell.second.textColor = #colorLiteral(red: 0.8643916561, green: 0.1293050488, blue: 0.007468156787, alpha: 1)
            cell.second.text = "NOT STARTED"
            cell.score.text = ""
        }
        if let assignedCoach = self.workouts[indexPath.section]["coach"] as? String{
            cell.coach.text = assignedCoach
        }else{
            cell.coach.text = ""
        }
        
        let exerciseNum = self.workouts[indexPath.section]["exercises"] as! [[String:AnyObject]]
        cell.exNumber.text = "Exercises: \(exerciseNum.count)"
        
        if timeToComplete != nil{
            let mins = timeToComplete! / 60
            let secs = timeToComplete! % 60
            cell.timeLabel.text = "Time: \(mins):\(secs)"
        }else{
            cell.timeLabel.text = ""
        }
        
        cell.accessoryType = .disclosureIndicator
        cell.layer.cornerRadius = 10
        cell.backgroundColor = #colorLiteral(red: 0.9160451311, green: 0.9251148849, blue: 0.9251148849, alpha: 1)
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return workouts.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return headerHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let background = UILabel()
        background.backgroundColor = #colorLiteral(red: 0, green: 0.4616597415, blue: 1, alpha: 1)
        return background
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let titleLabel = workouts[indexPath.section]["title"] as! String
        let complete = workouts[indexPath.section]["completed"] as! Bool
        let StoryBoard = UIStoryboard(name: "Main", bundle: nil)
        let SVC = StoryBoard.instantiateViewController(withIdentifier: "WorkoutDetailViewController") as! WorkoutDetailViewController
        SVC.username = PlayerActivityViewController.username
        SVC.titleString = titleLabel
        SVC.exercises = workouts[indexPath.section]["exercises"] as! [[String:AnyObject]]
        SVC.complete = complete
        SVC.workoutID = workoutIDs[indexPath.section]
        if let assignedCoach = self.workouts[indexPath.section]["coach"] as? String{
            SVC.assignedCoach = assignedCoach
        }else{
            SVC.assignedCoach = ""
        }
        PlayerWorkoutViewController.lastIndex = indexPath
        
        self.navigationController?.pushViewController(SVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            workouts.remove(at: indexPath.section)
            tableView.deleteRows(at: [indexPath], with: .left)
            DBref.child(self.username).setValue(workouts)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //loadUsername()
        loadWorkouts()
        tableview.reloadData()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func setScroll(){
        if let indexToScroll = PlayerWorkoutViewController.lastIndex{
            tableview.scrollToRow(at: indexToScroll, at: .middle, animated: true)
            PlayerWorkoutViewController.lastIndex = nil
        }
    }
    
    
    
    
    // working on displaying message for the first time
    // function
    override func viewDidAppear(_ animated: Bool) {
         if(!appDelegate.hasLaunchedWorkouts){
            //set hasAlreadyLaunched to false
            appDelegate.setLaunchedWorkouts()
            //display user agreement license
            // get width of screen to adjust alert appearance
            let screenSize: CGRect = UIScreen.main.bounds
            let screenWidth = screenSize.width
            
            let appearance = SCLAlertView.SCLAppearance(
                kWindowWidth: screenWidth - 40 )

            let alert = SCLAlertView(appearance: appearance)
            alert.showInfo("WORKOUTS", subTitle: "This page will display all of the workouts that your coach has set for you. You can get a detailed view by tapping on them!", closeButtonTitle: "GOT IT!", colorStyle: 0x347aeb, animationStyle: .bottomToTop)
        }
        setScroll()
    }


}
