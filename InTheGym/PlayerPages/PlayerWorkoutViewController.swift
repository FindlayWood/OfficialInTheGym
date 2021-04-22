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
    var handle:DatabaseHandle!
    var UsernameRef:DatabaseReference!
    var username:String = ""
    
    //array for workoutIDs, not sure this is needed? maybe it is. i forgot to copy to coach side
    //it is needed!
    var workoutIDs = [String]()
    
    // varibale to check for first time
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    // keep gaps between cells
    var headerHeight: CGFloat = 10.0
    
    // segment outlet and separate dicts
    @IBOutlet var segment:UISegmentedControl!
    var notStartedWorkouts : [[String:Any]] = []
    var inProgressWorkouts : [[String:Any]] = []
    var completedWorkouts : [[String:Any]] = []
    var rowsToDisplay : [[String:Any]] = []
    
    var notStartedIDs = [String]()
    var inProgressIDs = [String]()
    var completedIDs = [String]()
    var rowsToDisplayIDs = [String]()

    // varibale to store last index of where user was
    static var lastIndex : IndexPath?
    var myGroup = DispatchGroup()
    
    let userID = Auth.auth().currentUser?.uid
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableview.rowHeight = 150
        self.tableview.backgroundColor = Constants.lightColour
        
        let userID = Auth.auth().currentUser?.uid
        
        UsernameRef = Database.database().reference().child("users").child(userID!).child("username")
        DBref = Database.database().reference().child("Workouts").child(userID!)
        
        // added for selecting which workouts to view
        segment.addTarget(self, action: #selector(handleSegmentChange), for: .valueChanged)
        let NotSelectedTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 12)]
        let SelectedTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 12)]
        segment.setTitleTextAttributes(NotSelectedTextAttributes, for: .normal)
        segment.setTitleTextAttributes(SelectedTextAttributes, for: .selected)
        
    }
    
    @IBAction func addWorkoutPressed(_ sender:UIButton){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextVC = storyboard.instantiateViewController(withIdentifier: "AddWorkoutSelectionViewController") as! AddWorkoutSelectionViewController
        navigationController?.pushViewController(nextVC, animated: true)
    }
    
    func loadWorkouts(){
        self.workouts.removeAll()
        self.workoutIDs.removeAll()
        self.completedWorkouts.removeAll()
        self.completedIDs.removeAll()
        self.inProgressWorkouts.removeAll()
        self.inProgressIDs.removeAll()
        self.notStartedWorkouts.removeAll()
        self.notStartedIDs.removeAll()
        handle = DBref.observe(.childAdded, with: { (snapshot) in
            if let snap = snapshot.value as? [String:AnyObject]{
                
                self.workouts.insert(snap, at: 0)
                self.workoutIDs.insert(snapshot.key, at: 0)
                
                
                let startTime = snap["startTime"] as? Double
                let timeToComplete = snap["timeToComplete"] as? Int
                
                if snap["completed"] as! Bool == true {
                    self.completedWorkouts.insert(snap, at: 0)
                    self.completedIDs.insert(snapshot.key, at: 0)
                }else if startTime != nil && timeToComplete == nil{
                    self.inProgressWorkouts.insert(snap, at: 0)
                    self.inProgressIDs.insert(snapshot.key, at: 0)
                }else{
                    self.notStartedWorkouts.insert(snap, at: 0)
                    self.notStartedIDs.insert(snapshot.key, at: 0)
                }
                self.rowsToDisplay = self.workouts
                self.rowsToDisplayIDs = self.workoutIDs

            }
        }, withCancel: nil)
        
        DBref.observeSingleEvent(of: .value) { (_) in
            self.handleSegmentChange()
        }
    }
    
    func loadUsername(){
        UsernameRef.observeSingleEvent(of: .value) { (snapshot) in
            let snap = snapshot.value as! String
            self.username = snap
            //self.loadWorkouts()
        }
    }
    
    // added for selecting which workouts to display
    @objc fileprivate func handleSegmentChange(){
        switch segment.selectedSegmentIndex {
        case 0:
            rowsToDisplay = workouts
            rowsToDisplayIDs = workoutIDs
        case 1:
            rowsToDisplay = notStartedWorkouts
            rowsToDisplayIDs = notStartedIDs
        case 2:
            rowsToDisplay = inProgressWorkouts
            rowsToDisplayIDs = inProgressIDs
        case 3:
            rowsToDisplay = completedWorkouts
            rowsToDisplayIDs = completedIDs
        default:
            rowsToDisplay = workouts
            rowsToDisplayIDs = workoutIDs
        }
        tableview.reloadData()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableview.dequeueReusableCell(withIdentifier: "cell") as! TableViewCell
        let score = self.rowsToDisplay[indexPath.section]["score"] as? String
        let startTime = self.rowsToDisplay[indexPath.section]["startTime"] as? Double
        let timeToComplete = self.rowsToDisplay[indexPath.section]["timeToComplete"] as? Int
        let live = self.rowsToDisplay[indexPath.section]["liveWorkout"] as? Bool
        cell.timeImage.isHidden = true
        cell.main.text = self.rowsToDisplay[indexPath.section]["title"] as? String
        if self.rowsToDisplay[indexPath.section]["completed"] as! Bool == true{
            cell.second.textColor = #colorLiteral(red: 0.00234289733, green: 0.8251151509, blue: 0.003635218529, alpha: 1)
            cell.second.text = "COMPLETED"
            cell.score.text = "Score: \(score!)"
        }else if live == true{
            cell.second.textColor = #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1)
            cell.second.text = "LIVE"
            cell.score.text = ""
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
        
        if let createdBy = self.rowsToDisplay[indexPath.section]["createdBy"] as? String{
            cell.coach.text = createdBy
        }else if let assignedCoach = self.rowsToDisplay[indexPath.section]["coach"] as? String{
            cell.coach.text = assignedCoach
        }else{
            cell.coach.text = ""
        }
        
        if let exerciseNum = self.rowsToDisplay[indexPath.section]["exercises"] as? [[String:AnyObject]]{
            cell.exNumber.text = "Exercises: \(exerciseNum.count)"
        }else{
            cell.exNumber.text = "Exercises: 0"
        }
        
        
        if timeToComplete != nil{
            
            let formatter = DateComponentsFormatter()
            
            if timeToComplete! > 3600{
                formatter.allowedUnits = [.hour, .minute]
                formatter.unitsStyle = .abbreviated
            }else{
                formatter.allowedUnits = [.minute, .second]
                formatter.unitsStyle = .abbreviated
            }
            
            let timeString = formatter.string(from: TimeInterval(timeToComplete!))
            
            cell.timeLabel.text = timeString
            cell.timeImage.isHidden = false
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
        return rowsToDisplay.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return headerHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let background = UILabel()
        background.backgroundColor = Constants.lightColour
        return background
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let titleLabel = self.rowsToDisplay[indexPath.section]["title"] as! String
        let complete = self.rowsToDisplay[indexPath.section]["completed"] as! Bool
        let StoryBoard = UIStoryboard(name: "Main", bundle: nil)
//        let SVC = StoryBoard.instantiateViewController(withIdentifier: "WorkoutDetailViewController") as! WorkoutDetailViewController
//        SVC.username = ViewController.username
//        SVC.playerID = self.userID!
//        SVC.titleString = titleLabel
//        WorkoutDetailViewController.exercises = self.rowsToDisplay[indexPath.section]["exercises"] as! [[String:AnyObject]]
//        SVC.complete = complete
//        SVC.workoutID = rowsToDisplayIDs[indexPath.section]
//        SVC.fromDiscover = false
//        SVC.creatorID = rowsToDisplay[indexPath.section]["creatorID"] as! String
//
//        if let savedID = rowsToDisplay[indexPath.section]["savedID"] as? String {
//            SVC.savedID = savedID
//        }
//        SVC.creatorUsername = rowsToDisplay[indexPath.section]["createdBy"] as! String
//        if let assignedCoach = self.rowsToDisplay[indexPath.section]["coach"] as? String{
//            SVC.assignedCoach = assignedCoach
//        }else{
//            SVC.assignedCoach = ""
//        }
//        if let live = rowsToDisplay[indexPath.section]["liveWorkout"] as? Bool{
//            if live == true && complete == false {
//                SVC.liveAdd = true
//            } else {
//                SVC.liveAdd = false
//            }
//        }
//        PlayerWorkoutViewController.lastIndex = indexPath
//
//        self.navigationController?.pushViewController(SVC, animated: true)
        let DisplayVC = StoryBoard.instantiateViewController(withIdentifier: "DisplayWorkoutViewController") as! DisplayWorkoutViewController
        let workoutID = rowsToDisplayIDs[indexPath.section]
        let ref = Database.database().reference().child("Workouts").child(self.userID!).child(workoutID)
        ref.observeSingleEvent(of: .value) { (snapshot) in
            let workoutToDisplay = workout(snapshot: snapshot)
            DisplayVC.selectedWorkout = workoutToDisplay
            self.navigationController?.pushViewController(DisplayVC, animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadWorkouts()
        tableview.reloadData()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    override func viewDidDisappear(_ animated: Bool) {
        DBref.removeObserver(withHandle: handle)
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
            alert.showInfo("WORKOUTS", subTitle: "This page will display all of the workouts that your coach has set for you. Switch between workouts you have not started, workouts that are in progress and workouts you have completed easily with the switch bar at the top. You can get a detailed view by tapping on them!", closeButtonTitle: "GOT IT!", colorStyle: 0x347aeb, animationStyle: .bottomToTop)
        }
    }


}
