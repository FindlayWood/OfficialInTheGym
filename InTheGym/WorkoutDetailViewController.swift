//
//  WorkoutDetailViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 09/07/2019.
//  Copyright © 2019 FindlayWood. All rights reserved.
//

import UIKit
import Firebase
import SCLAlertView

class WorkoutDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, infoButtonsDelegate, noteButtonDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    // variables passed from previous page - username and workout title
    // username is always username of player
    // assigned coach - the coach username who assigned the workout
    var username: String = ""
    var titleString: String = ""
    var assignedCoach: String = ""
    
    //number of workouts completed
    var numberCompleted:Int!
    
    //boolean variable if workout is completed
    var complete: Bool!
    
    //array of exercises for workout
    var exercises: [[String:AnyObject]] = []
    
    //array of workouts and activities, may not be needed anymore
    var workouts: [[String:AnyObject]] = []
    var activies: [[String:AnyObject]] = []
    
    //database references
    var DBRef:DatabaseReference!
    var ActRef:DatabaseReference!
    var ComRef:DatabaseReference!
    var ScoreRef: DatabaseReference!
    var CoachRef: DatabaseReference!
    var feedRef: DatabaseReference!
    
    //parentviewcontroller variable, may not be needed
    var PVC: ViewWorkoutViewController!
    
    //outlet variables to button and tableview
    @IBOutlet var completeButton:UIButton!
    @IBOutlet var tableview:UITableView!
    
    // constraint outlet
    @IBOutlet var buttonConstraint:NSLayoutConstraint!
    @IBOutlet var bottomButton: NSLayoutConstraint!
    
    
    //workout ID string for update
    var workoutID: String = ""
    
    // key for coach, not used
    var adminkey: String = ""
    
    // coachname varibale if player loads the page
    var coachName: String = ""
    
    // array of coach ids for 1.4
    var coaches = [String]()
    
    // array of colours to set rpe button
    let colors = [#colorLiteral(red: 0, green: 0.5, blue: 1, alpha: 1), #colorLiteral(red: 0.6332940925, green: 0.8493953339, blue: 1, alpha: 1), #colorLiteral(red: 0.7802333048, green: 1, blue: 0.5992883134, alpha: 1), #colorLiteral(red: 0.9427440068, green: 1, blue: 0.3910798373, alpha: 1), #colorLiteral(red: 1, green: 1, blue: 0, alpha: 1), #colorLiteral(red: 1, green: 0.8438837757, blue: 0, alpha: 1), #colorLiteral(red: 1, green: 0.7074058219, blue: 0, alpha: 1), #colorLiteral(red: 1, green: 0.4706228596, blue: 0, alpha: 1), #colorLiteral(red: 1, green: 0.3134631849, blue: 0, alpha: 1), #colorLiteral(red: 1, green: 0, blue: 0, alpha: 1)]
    
    // counter to get the correct collection view
    var counter = 0
    
    // array of collectionviews for an experiment
    var collections = [UICollectionView]()
    
    // bottom view to display when workout has not begun
    var workoutBegun : Bool!
    var startTime : TimeInterval!
    var timer = Timer()
    var seconds : Int = 0
    var flashView = UIView()
    var flashLabel = UILabel()
    
    @IBOutlet weak var beginView:UIView!
    @IBOutlet var bottomViewHeight: NSLayoutConstraint!
    @IBOutlet var bottomViewBottomAnchor: NSLayoutConstraint!
    
    // queue to order events
    let myGroup = DispatchGroup()
    
    
    
    @IBAction func completed(_ sender:UIButton){
        sender.pulsate()
// MARK: can no longer uncomplete workout. was part of 1.3 therefore below can go
        if complete == true{
            let alert = UIAlertController(title: "Uncomplete", message: "Are you sure this workout is uncomplete?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (UIAlertAction) in
                self.DBRef.child("\(self.workoutID)").updateChildValues(["completed" : false])
                self.DBRef.child("\(self.workoutID)").updateChildValues(["score" : ""])
                self.completeButton.setTitle("COMPLETED", for: .normal)
                let actData = ["time":ServerValue.timestamp(),
                               "message":"You uncompleted the workout \(self.titleString).",
                            "type":"Workout UnCompleted"] as [String:AnyObject]
                //self.activies.insert(actData, at: 0)
                //self.ActRef.setValue(self.activies)
                self.ActRef.childByAutoId().setValue(actData)
                self.numberCompleted -= 1
                self.ComRef.child("numberOfCompletes").setValue(self.numberCompleted)
                self.navigationController?.popViewController(animated: true)
                
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        }
        else if complete == false{
            
            let endTime = Date.timeIntervalSinceReferenceDate
            var mins:Int = 0
            var secs:Int = 0
            var timeToComplete : Int = 0
            self.DBRef.child("\(self.workoutID)").child("startTime").observeSingleEvent(of: .value) { (snapshot) in
                
                if let snap = snapshot.value as? Double{
                    let startTime = Int(snap)
                    
                    let completionTimeSeconds = Int(endTime) - startTime
                    timeToComplete = completionTimeSeconds
                    mins = Int(completionTimeSeconds / 60)
                    secs = Int(completionTimeSeconds % 60)
                    print("\(mins) mins, \(secs) secs")
                }
            }
            
            // set scoreref
            ScoreRef = Database.database().reference().child("Scores")
            let userID = Auth.auth().currentUser?.uid
            
            // new alert - bigger one coming
            let alert = SCLAlertView()
            let score = alert.addTextField()
            score.placeholder = "RPE score from 1 to 10..."
            score.keyboardType = .numberPad
            score.becomeFirstResponder()
            alert.addButton("Upload") {
                if score.text == "" {
                    self.showError()
                }else if Int((score.text)!)! < 1 || Int((score.text)!)! > 10{
                    self.showError()
                }else{
                    self.DBRef.child("\(self.workoutID)").updateChildValues(["completed" : true])
                    let scoreNum = score.text!
                    self.DBRef.child("\(self.workoutID)").updateChildValues(["score" : scoreNum])
                    //self.ScoreRef.updateChildValues([self.titleString:scoreNum])
                    self.completeButton.setTitle("UNCOMPLETED", for: .normal)
                    let actData = ["time":ServerValue.timestamp(),
                                   "message":"You completed the workout \(self.titleString).",
                                    "type":"Workout Completed"] as [String:AnyObject]
                    //self.activies.insert(actData, at: 0)
                    //self.ActRef.setValue(self.activies)
                    self.ActRef.childByAutoId().setValue(actData)
                    self.numberCompleted += 1
                    self.ComRef.child("numberOfCompletes").setValue(self.numberCompleted)
                    if ViewController.admin == false{
                        let actData2 = ["time":ServerValue.timestamp(),
                        "message":"\(self.username) completed the workout \(self.titleString).",
                        "type":"Workout Completed"] as [String:AnyObject]
                        
// MARK: commented out to trial new loop below
                        //self.feedRef.child(self.coachName).childByAutoId().setValue(actData2)
                        let scoreInfo = [self.titleString:scoreNum]
// MARK: new section for looping coaches, adding activity and scores
                        for coach in self.coaches{
                            
                            // loop all coaches and add activity to public feed

                            self.feedRef.child(coach).childByAutoId().setValue(actData2)
                            //self.ScoreRef.child(coach).child(userID!).setValue(scoreInfo)

                        }
// end of new section
                        
                        
                        // newest section
                        // only a player can complete a workout therefor a coach can never get to this section.
                        // this is where the crash occured in version 2 when completing a GROUP workout.
                        // version 2.1 resolves this issue
                        self.ScoreRef.child(self.assignedCoach).childByAutoId().setValue(scoreInfo)
                        self.ScoreRef.child(self.username).childByAutoId().setValue(scoreInfo)
                    }
                    self.DBRef.child("\(self.workoutID)").updateChildValues(["timeToComplete":timeToComplete])
                    
                    self.navigationController?.popViewController(animated: true)
                    
                }
            }
            
            alert.showSuccess("Completed!", subTitle: "Enter RPE score to complete upload. Workout Time = \(mins) minutes, \(secs) seconds", closeButtonTitle: "Cancel")
        }
    }
    
    func showError(){
        // new alert
        let alert = SCLAlertView()
        alert.showError("Error", subTitle: "Enter a score between 1 and 10", closeButtonTitle: "ok", animationStyle: .noAnimation)
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        self.tableview.rowHeight = 380
        let userID = Auth.auth().currentUser?.uid
        
        if complete == true || ViewController.admin == true{
            completeButton.isHidden = true
            // set tableview to very bottom
            bottomButton.constant = 50
            completeButton.setTitle("UNCOMPLETED", for: .normal)
            
            flashView.isHidden = true
            beginView.isHidden = true
        }
        
        
        // flashview
        flashView.frame = self.view.frame
        flashView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5)
        self.view.insertSubview(flashView, at: 2)
        flashView.isUserInteractionEnabled = false
        
        // label in flashview
        flashView.addSubview(flashLabel)
        flashLabel.translatesAutoresizingMaskIntoConstraints = false
        flashLabel.centerXAnchor.constraint(equalTo: flashView.centerXAnchor).isActive = true
        flashLabel.centerYAnchor.constraint(equalTo: flashView.centerYAnchor).isActive = true
        flashLabel.text = titleString
        flashLabel.textColor = .clear
        flashLabel.font = .boldSystemFont(ofSize: 30)
        
        
        
        // bottom view
        let screenSize = view.frame.size
        bottomViewHeight.constant = screenSize.height / 4
        beginView.layer.cornerRadius = 10
        beginView.backgroundColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)
        beginView.layer.shadowColor = UIColor.black.cgColor
        beginView.layer.shadowOffset = CGSize(width: 0, height: 5.0)
        beginView.layer.shadowRadius = 10.0
        beginView.layer.shadowOpacity = 1.0
        beginView.layer.masksToBounds = false
        
        
        
        
        
        
        navigationItem.title = titleString
        DBRef = Database.database().reference().child("Workouts").child(username)
        ActRef = Database.database().reference().child("users").child(userID!).child("activities")
        ComRef = Database.database().reference().child("users").child(userID!)
        feedRef = Database.database().reference().child("Public Feed")
        
// MARK: change the location of score ref to use user ids
// below can change as now a coach can not complete a workout
        if ViewController.admin == true{
            //ScoreRef = Database.database().reference().child("Scores").child(AdminActivityViewController.username).child(username)
        }
        else{
            //ScoreRef = Database.database().reference().child("Scores").child(PlayerActivityViewController.coachName).child(userID!)
            //CoachRef = Database.database().reference().child("users")
            loadCoachName()
        }
        //ScoreRef = Database.database().reference().child("Scores").child(userID!).child(username)
        loadActivities()
        loadNumberOfCompletes()
       
    }
    // function to load the uid of coach to update their activity feed
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableview.dequeueReusableCell(withIdentifier: "cell") as! DetailTableViewCell
        //let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        // next 5 lines for collectionview
        cell.collection.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        let indexPath2 = IndexPath(item: 0, section: 0)
        cell.collection.scrollToItem(at: indexPath2, at: .left, animated: false)
        self.counter = indexPath.section
        cell.collection.tag = indexPath.section
        cell.collection.reloadData()

        
        // hiding the textfields
        cell.repsTextField.isHidden = true
        cell.setsTextField.isHidden = true
        //cell.weightLabel.isHidden = true
        
        cell.layer.cornerRadius = 10
        cell.layer.masksToBounds = true
        cell.delegate = self
        cell.ndelegate = self
        cell.indexPath = indexPath
        cell.weightLabel.text = ""
        cell.rpeButton.setTitle("RPE", for: .normal)
        cell.rpeButton.setTitleColor(#colorLiteral(red: 0, green: 0.4618991017, blue: 1, alpha: 1), for: .normal)
        cell.accessoryType = .none
        let exercise = exercises[indexPath.section]["exercise"] as! String
        //let reps = exercises[indexPath.section]["reps"] as! String
        let sets = exercises[indexPath.section]["sets"] as! String
        if let reps = exercises[indexPath.section]["reps"] as? String{
            let setInt = Int(sets)!
            var x = 0
            var repString = ""
            while x < setInt {
                repString += reps
                if x != setInt - 1{
                    repString += ","
                }
                x += 1
            }
            cell.repsLabel.text = repString
        }
        if let repArray = exercises[indexPath.section]["reps"] as? [String]{
            var repString = ""
            for rep in repArray{
                repString += rep
                repString += ","
            }
            cell.repsLabel.text = String(repString.dropLast())
        }
        cell.setsLabel.text = "\(sets) SETS"
        if let weight = exercises[indexPath.section]["weight"] as? String{
            if weight == ""{
                cell.exerciseLabel.text = "\(exercise)"
                cell.setsTextField.text = "\(sets)"
                //cell.repsTextField.text = "\(reps)"
            }
            else{
                cell.exerciseLabel.text = "\(exercise)"
                cell.setsTextField.text = "\(sets)"
                //cell.repsTextField.text = "\(reps)"
                //cell.weightLabel.text = "\(weight)"
                let setInt = Int(sets)!
                var x = 0
                var weightString = ""
                while x < setInt {
                    weightString += weight
                    weightString += ","
                    x += 1
                }
                cell.weightLabel.text = weight
            }
        }
        if let rpe = exercises[indexPath.section]["rpe"] as? String{
            cell.rpeButton.setTitle("\(rpe)", for: .normal)
            let colourIndex = Int(rpe)!-1
            cell.rpeButton.setTitleColor(colors[colourIndex], for: .normal)
        }
        
        // checking if there is a note and deciding whether to display the button
        if (exercises[indexPath.section]["note"] as? String) != nil{
            cell.noteButton.isHidden = false
        }else{
            cell.noteButton.isHidden = true
        }
        
        // checking if workout complete or user is coach and then enabling rpe button or not
        if ViewController.admin == true || complete == true || workoutBegun == false{
            cell.rpeButton.isUserInteractionEnabled = false
        }
        
        // converting the rep var into a list of reps
//        let setInt = Int(sets)!
//        var x = 0
//        var repString = ""
//        while x < setInt {
//            repString += reps
//            if x != setInt - 1{
//                repString += ","
//            }
//            x += 1
//        }
//        cell.repsLabel.text = repString
        
        
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return exercises.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = "EXERCISE \(section+1)"
        label.font = .boldSystemFont(ofSize: 15)
        label.font = .preferredFont(forTextStyle: UIFont.TextStyle(rawValue: "Menlo Bold"))
        label.backgroundColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
        label.textAlignment = .center
        label.textColor = UIColor.white
        
        return label
    }
    
    // add check mark to tick off each exercise
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("detetced tap in row \(indexPath.section)")
    }
    
    // MARK: functions for the collection view
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sets = exercises[collectionView.tag]["sets"] as! String
        let setInt = Int(sets)!
        return setInt

    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! InsideCollectionViewCell
        cell.layer.cornerRadius = 10
        cell.contentView.layer.cornerRadius = 10
        //cell.layer.borderWidth = 2
        cell.contentView.layer.borderWidth = 2
        //cell.layer.borderColor = UIColor.black.cgColor
        cell.contentView.layer.borderColor = UIColor.black.cgColor
        //cell.layer.masksToBounds = true
        cell.contentView.layer.masksToBounds = true
        cell.backgroundColor = #colorLiteral(red: 0, green: 0.4618991017, blue: 1, alpha: 1)
        
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 5.0)
        cell.layer.shadowRadius = 6.0
        cell.layer.shadowOpacity = 1.0
        cell.layer.masksToBounds = false
        //cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: cell.contentView.layer.cornerRadius).cgPath


        let collectionIndex = collectionView.tag
        
//        let reps = exercises[collectionIndex]["reps"] as! String
//        cell.repsLabel.text = "\(reps) reps"
        
        let sets = exercises[collectionIndex]["sets"] as! String

        if let reps = exercises[collectionIndex]["reps"] as? String{
            
            cell.repsLabel.text = "\(reps) reps"
        }
        if let repArray = exercises[collectionIndex]["reps"] as? [String]{
            
            cell.repsLabel.text = "\(repArray[indexPath.row]) reps"
        }
        
        
        if let weight = exercises[collectionIndex]["weight"] as? String{
            cell.weightLabel.text = "\(weight)"
        }

        cell.setLabels.text = "SET \(indexPath.row + 1)"
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let lastIndexToScroll = collectionView.numberOfItems(inSection: 0) - 1
        if indexPath.row < lastIndexToScroll{
            let indexToScroll = IndexPath.init(row: indexPath.row + 1, section: 0)
            collectionView.scrollToItem(at: indexToScroll, at: .left, animated: true)
        }
        
    }
    
    
    
    //may not need this function with autoID
    func loadActivities(){
        ActRef.observe(.childAdded, with: { (snapshot) in
            if let snap = snapshot.value as? [String:AnyObject]{
                self.activies.append(snap)
            }
        }, withCancel: nil)
    }
    
    //function to update the number of completed workouts
    func loadNumberOfCompletes(){
        ComRef.child("numberOfCompletes").observeSingleEvent(of: .value) { (snapshot) in
            let count = snapshot.value as? Int
            self.numberCompleted = count ?? 0
        }
    }
    
    // load coachname
    func loadCoachName(){
        ComRef.child("coachName").observeSingleEvent(of: .value) { (snapshot) in
            let snap = snapshot.value as! String
            self.coachName = snap
        }
        
        // load array of coaches and set variable equal
        ComRef.child("coaches").observe(.childAdded) { (snapshot) in
            if let snap = snapshot.value as? String{
                self.coaches.append(snap)
            }
        }
        
    }
    
    // load info tapped
    func infoButtonTapped(at index: IndexPath){
        let alert = SCLAlertView()
        alert.showInfo("Info", subTitle: "You tapped on info for \(exercises[index[0]]["exercise"] as! String)")
    }
    
    // display alert view with note in it and allows edit
    func noteButtonTapped(at index: IndexPath){
        // setting width to screen width - 40
        // first get screen size then set alert
        let screenSize: CGRect = UIScreen.main.bounds
        let screenWidth = screenSize.width
        
        let appearance = SCLAlertView.SCLAppearance(
            kWindowWidth: screenWidth - 40, kTextViewdHeight: 120 )
        let alert = SCLAlertView(appearance: appearance)
        let coachText = alert.addTextView()
        coachText.text = "this is a note from the coach"
        coachText.textColor = .lightGray
        coachText.textContainer.maximumNumberOfLines = 5
        coachText.textContainer.lineBreakMode = .byTruncatingTail
        coachText.isScrollEnabled = false
        coachText.isUserInteractionEnabled = false
        coachText.layer.cornerRadius = 6
        if ViewController.admin == false{
            coachText.isUserInteractionEnabled = false
        }
        if let note = exercises[index.section]["note"] as? String{
            coachText.textColor = .black
            coachText.text = note
        }else{
            coachText.text = "no note from coach"
        }
        
        alert.showInfo("Exercise note", subTitle: "Notes for this exercise from your coach.", closeButtonTitle: "close")
    }
    
    // MARK: exercise rpe
    func rpeButtonTapped(at index: IndexPath, sender:UIButton, view: UICollectionView) {
        let alert = SCLAlertView()
        let rpe = alert.addTextField()
        rpe.placeholder = "enter rpe 1-10..."
        rpe.keyboardType = .numberPad
        rpe.becomeFirstResponder()
        alert.addButton("SAVE") {
            if rpe.text == "" {
                self.showError()
            }else if Int((rpe.text)!)! < 1 || Int((rpe.text)!)! > 10{
                self.showError()
            }else{
                let colourIndex = Int(rpe.text!)!-1
                sender.setTitle("\(rpe.text!)", for: .normal)
                self.exercises[index.section]["rpe"] = rpe.text as AnyObject?
                print(self.exercises[index.section])
                self.DBRef.child(self.workoutID).updateChildValues(["exercises" : self.exercises])
                let cellIndex = IndexPath.init(row: 0, section: index.section)
                let row = self.tableview.cellForRow(at: cellIndex)
                UIView.animate(withDuration: 0.5) {
                    row?.backgroundColor = self.colors[colourIndex]
                    view.backgroundColor = self.colors[colourIndex]
                    
                    //sender.titleLabel?.font = UIFont.boldSystemFont(ofSize: 30)
                    sender.setTitleColor(self.colors[colourIndex], for: .normal)
                } completion: { (_) in
                    UIView.animate(withDuration: 0.5) {
                        row?.backgroundColor =  #colorLiteral(red: 0.9251794815, green: 0.9334231019, blue: 0.9333136678, alpha: 1)
                        view.backgroundColor = #colorLiteral(red: 0.9251794815, green: 0.9334231019, blue: 0.9333136678, alpha: 1)
                    } completion: { (_) in
                        let lastIndexToScroll = self.tableview.numberOfSections - 1
                        if index.section < lastIndexToScroll{
                            let indexToScroll = IndexPath.init(row: 0, section: index.section + 1)
                            self.tableview.scrollToRow(at: indexToScroll, at: .top, animated: true)
                        }
                    }
                }

            }
            
            
        }
        alert.showSuccess("RPE", subTitle: "Enter rpe for \(exercises[index[0]]["exercise"] as! String)",closeButtonTitle: "cancel")
    }
    
    @IBAction func workoutHasBegun(_ sender:UIButton){
        self.workoutBegun = true
        self.flashLabel.isHidden = false
        startTime = Date.timeIntervalSinceReferenceDate
        self.DBRef.child("\(self.workoutID)").updateChildValues(["startTime" : startTime!])
        
        UIView.animate(withDuration: 1) {
            self.flashView.backgroundColor = UIColor.white
            self.flashLabel.textColor = .black
            self.beginView.frame.origin.y += self.beginView.frame.height + 50
        } completion: { (_) in
            self.beginView.isHidden = true
            UIView.animate(withDuration: 0.4) {
                self.flashView.backgroundColor = .clear
                self.flashLabel.textColor = .clear
            } completion: { (_) in
                self.flashView.removeFromSuperview()
            }
        }

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    

}
