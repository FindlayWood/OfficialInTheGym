//
//  ViewWorkoutViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 09/07/2019.
//  Copyright © 2019 FindlayWood. All rights reserved.
//

// coach page

import UIKit
import Firebase

class ViewWorkoutViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var username:String = ""
    var workouts : [[String:Any]] = []
    
    var playerID : String!
    
    //array for workout ids, after update stored in different way
    var workoutIDs = [String]()
    
    //databse reference variable
    var DBRef : DatabaseReference!
    var handle : DatabaseHandle!
    
    //outlet to tableview
    @IBOutlet var tableview:UITableView!
    
    var headerHeight: CGFloat = 10.0
    
    @IBOutlet var segment:UISegmentedControl!
    var notStartedWorkouts : [[String:Any]] = []
    var inProgressWorkouts : [[String:Any]] = []
    var completedWorkouts : [[String:Any]] = []
    var rowsToDisplay : [[String:Any]] = []
    
    var notStartedIDs = [String]()
    var inProgressIDs = [String]()
    var completedIDs = [String]()
    var rowsToDisplayIDs = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Workouts"
        self.tableview.rowHeight = 150
        self.tableview.backgroundColor = Constants.lightColour
        
        // added for selecting which workouts to view
        segment.addTarget(self, action: #selector(handleSegmentChange), for: .valueChanged)
        let NotSelectedTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 12)]
        let SelectedTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 12)]
        segment.setTitleTextAttributes(NotSelectedTextAttributes, for: .normal)
        segment.setTitleTextAttributes(SelectedTextAttributes, for: .selected)
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
        handle = DBRef.observe(.childAdded, with: { (snapshot) in
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
        
        DBRef.observeSingleEvent(of: .value) { (_) in
            self.handleSegmentChange()
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
        cell.timeImage.isHidden = true
        cell.main.text = self.rowsToDisplay[indexPath.section]["title"] as? String
        if self.rowsToDisplay[indexPath.section]["completed"] as! Bool == true{
            cell.second.textColor = #colorLiteral(red: 0.002346782246, green: 0.8264833299, blue: 0.00364124633, alpha: 1)
            cell.second.text = "COMPLETED"
            cell.score.text = "Score: \(score!)"
        }else if startTime != nil && timeToComplete == nil{
            cell.second.textColor = #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1)
            cell.second.text = "IN PROGRESS"
            cell.score.text = ""
            PlayerWorkoutViewController.lastIndex = indexPath
        }else{
            cell.second.textColor = #colorLiteral(red: 0.8518797589, green: 0.1274333839, blue: 0.007360056703, alpha: 1)
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
        
        let exerciseNum = self.rowsToDisplay[indexPath.section]["exercises"] as! [[String:AnyObject]]
        cell.exNumber.text = "Exercises: \(exerciseNum.count)"
        
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
        
        let titleLabel = rowsToDisplay[indexPath.section]["title"] as! String
        let complete = rowsToDisplay[indexPath.section]["completed"] as! Bool
        let StoryBoard = UIStoryboard(name: "Main", bundle: nil)
//        let SVC = StoryBoard.instantiateViewController(withIdentifier: "WorkoutDetailViewController") as! WorkoutDetailViewController
//        SVC.username = self.username
//        SVC.playerID = self.playerID
//        SVC.titleString = titleLabel
//        WorkoutDetailViewController.exercises = rowsToDisplay[indexPath.section]["exercises"] as! [[String:AnyObject]]
//        SVC.complete = complete
//        SVC.workoutID = rowsToDisplayIDs[indexPath.section]
//        if let assignedCoach = self.rowsToDisplay[indexPath.section]["coach"] as? String{
//            SVC.assignedCoach = assignedCoach
//        }else{
//            SVC.assignedCoach = ""
//        }
//        SVC.liveAdd = false
//        SVC.fromDiscover = false
//        self.navigationController?.pushViewController(SVC, animated: true)
        
        let DisplayVC = StoryBoard.instantiateViewController(withIdentifier: "DisplayWorkoutViewController") as! DisplayWorkoutViewController
        let workoutID = rowsToDisplayIDs[indexPath.section]
        let ref = Database.database().reference().child("Workouts").child(self.playerID).child(workoutID)
        ref.observeSingleEvent(of: .value) { (snapshot) in
            let workoutToDisplay = workout(snapshot: snapshot)
            DisplayVC.selectedWorkout = workoutToDisplay
            self.navigationController?.pushViewController(DisplayVC, animated: true)
        }
    }
    
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete{
//            rowsToDisplay.remove(at: indexPath.section)
//            tableView.deleteRows(at: [indexPath], with: .left)
//            DBRef.setValue(rowsToDisplay)
//        }
//
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        let textAttributes = [NSAttributedString.Key.foregroundColor:#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)]
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        DBRef = Database.database().reference().child("Workouts").child(playerID)
        loadWorkouts()
    }
    override func viewDidDisappear(_ animated: Bool) {
        DBRef.removeObserver(withHandle: handle)
    }
}
