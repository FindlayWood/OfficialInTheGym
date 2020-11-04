//
//  ViewWorkoutViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 09/07/2019.
//  Copyright © 2019 FindlayWood. All rights reserved.
//

import UIKit
import Firebase

class ViewWorkoutViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var username:String = ""
    var workouts : [[String:Any]] = []
    
    //array for workout ids, after update stored in different way
    var workoutIDs = [String]()
    
    //databse reference variable
    var DBRef : DatabaseReference!
    
    //outlet to tableview
    @IBOutlet var tableview:UITableView!
    
    var headerHeight: CGFloat = 10.0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Workouts"
        self.tableview.rowHeight = 130
        self.tableview.backgroundColor = #colorLiteral(red: 0, green: 0.4618991017, blue: 1, alpha: 1)
        
    }
    
    func loadWorkouts(){
        workouts.removeAll()
        DBRef.observe(.childAdded, with: { (snapshot) in
            if let snap = snapshot.value as? [String:AnyObject]{
                self.workouts.insert(snap, at: 0)
                self.tableview.reloadData()
            }
        }, withCancel: nil)
        
        workoutIDs.removeAll()
        DBRef.observe(.value) { (snapshot) in
            for snap in snapshot.children{
                let userSnap = snap as! DataSnapshot
                self.workoutIDs.insert(userSnap.key, at: 0)
            }
            print(self.workoutIDs)
        }
        
        
       
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableview.dequeueReusableCell(withIdentifier: "cell") as! TableViewCell
        let score = self.workouts[indexPath.section]["score"] as? String
        cell.main.text = self.workouts[indexPath.section]["title"] as? String
        if self.workouts[indexPath.section]["completed"] as! Bool == true{
            cell.second.textColor = #colorLiteral(red: 0, green: 0.9768045545, blue: 0, alpha: 1)
            cell.second.text = "COMPLETED"
            cell.score.text = "Score: \(score!)"
        }else{
            cell.second.textColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
            cell.second.text = "UNCOMPLETED"
            cell.score.text = ""
        }
        
        if let assignedCoach = self.workouts[indexPath.section]["coach"] as? String{
            cell.coach.text = assignedCoach
        }else{
            cell.coach.text = ""
        }
        
        let exerciseNum = self.workouts[indexPath.section]["exercises"] as! [[String:AnyObject]]
        cell.exNumber.text = "Exercises: \(exerciseNum.count)"
        
        if let time = self.workouts[indexPath.section]["timeToComplete"] as? Int{
            let mins = time / 60
            let secs = time % 60
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
        background.backgroundColor = #colorLiteral(red: 0, green: 0.4618991017, blue: 1, alpha: 1)
        return background
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let titleLabel = workouts[indexPath.section]["title"] as! String
        let complete = workouts[indexPath.section]["completed"] as! Bool
        let StoryBoard = UIStoryboard(name: "Main", bundle: nil)
        let SVC = StoryBoard.instantiateViewController(withIdentifier: "WorkoutDetailViewController") as! WorkoutDetailViewController
        SVC.username = self.username
        SVC.titleString = titleLabel
        SVC.exercises = workouts[indexPath.section]["exercises"] as! [[String:AnyObject]]
        SVC.complete = complete
        SVC.workoutID = workoutIDs[indexPath.section]
        if let assignedCoach = self.workouts[indexPath.section]["coach"] as? String{
            SVC.assignedCoach = assignedCoach
        }else{
            SVC.assignedCoach = ""
        }
        
        self.navigationController?.pushViewController(SVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            workouts.remove(at: indexPath.section)
            tableView.deleteRows(at: [indexPath], with: .left)
            DBRef.setValue(workouts)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        let textAttributes = [NSAttributedString.Key.foregroundColor:#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)]
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        DBRef = Database.database().reference().child("Workouts").child(username)
        loadWorkouts()
        tableview.reloadData()
        
    }
}
