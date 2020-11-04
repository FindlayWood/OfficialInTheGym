//
//  AddWorkoutHomeViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 04/07/2019.
//  Copyright © 2019 FindlayWood. All rights reserved.
//
// add workout for single player. coaches page
// coaches page

import UIKit
import Firebase
import Flurry_iOS_SDK
import SCLAlertView
import EmptyDataSet_Swift


class AddWorkoutHomeViewController: UIViewController, UITableViewDataSource,UITableViewDelegate, EmptyDataSetSource, EmptyDataSetDelegate {
    
    //outlets to text field and tableview
    @IBOutlet weak var titleField:UITextField!
    @IBOutlet weak var tableview:UITableView!
    
    // username of player
    var userName:String!
    
    // database referneces
    var DBRef:DatabaseReference!
    var ActRef:DatabaseReference!
    var GroupDBRef:DatabaseReference!
    
    // number of workouts, to be updated if new one added
    var workoutsCount:Int!
    
    // array of activity feed to be updated, may not need anympre
    var activities:[[String:AnyObject]] = []
    
    // user id of curent user
    let userID = Auth.auth().currentUser!.uid
    
    // array of exercises and workouts, may not need workouts
    static var exercises :[[String:Any]] = []
    static var workouts :[[String:Any]] = []
    
    // stepper
    @IBOutlet weak var stepper:UIStepper!
    @IBOutlet weak var stepLabel:UILabel!
    var stepCount: Int = 1
    @IBAction func stepperChanged(_ sender:UIStepper){
        stepCount = Int(sender.value)
        stepLabel.text = ":" + stepCount.description
    }
    
    // new add button above tableview
    @IBOutlet weak var addButton:UIButton!
    @IBAction func buttonPulsate(_ sender:UIButton){sender.pulsate()}
    
    // the 2 views behind items
    @IBOutlet weak var topView:UIView!
    @IBOutlet weak var bottomView:UIView!
    // height of the top view
    @IBOutlet var TopViewHeight: NSLayoutConstraint!
    // the upload button
    @IBOutlet weak var uploadButton:UIButton!
    
    // variables to check if group or single.
    static var groupBool:Bool!
    var groupPlayers = [String]()
    let myGroup = DispatchGroup()
        
    
    @IBAction func savePressed(_ sender:UIButton){
        Flurry.logEvent("Single add workout - Save Pressed.")
        
        print("you want to upload this multiple times, \(stepCount) times to be exact. now we have to go to a new page to allow edits to 2nd or 3rd")
        
        
        if titleField.text == ""{
            
            // new alert
            let alert = SCLAlertView()
            alert.showWarning("OOPS!", subTitle: "Please enter a title.", closeButtonTitle: "Ok")
            
        }else if AddWorkoutHomeViewController.exercises.count == 0{
            // new alert
            let alert = SCLAlertView()
            alert.showWarning("OOPS!", subTitle: "You must enter at least one exercise. Add exercises by tapping the Add Exercise button.", closeButtonTitle: "Ok")
            
        }else{
            let username = AdminActivityViewController.username
            let exerciseData = ["title": titleField.text!,
                                "completed": false,
                                "exercises": AddWorkoutHomeViewController.exercises,
                                "coach": username] as [String : Any]
            
            
            
            
            // need to rewrite this section for if group, then if multiple
            
            // begin with group check
            if AddWorkoutHomeViewController.groupBool{
                // this is for a group add
                // then add check for multiple
                if stepCount > 1{
                    // MARK: GROUP Multiple
                    // multiple add for a group
                    // in here add loop to add for stepcount times
                    myGroup.enter()
                    for _ in 1...stepCount{
                        for player in groupPlayers{
                            self.GroupDBRef.child(player).childByAutoId().setValue(exerciseData)
                        }
                    }
                    myGroup.leave()
                    myGroup.notify(queue: DispatchQueue.main){
                        let actData = ["time":ServerValue.timestamp(),
                                       "type":"Set Workout",
                                       "message":"You created \(self.stepCount) group Workouts."] as [String:AnyObject]
                        self.ActRef.child("users").child(self.userID).child("activities").childByAutoId().setValue(actData)
                                            
                        self.workoutsCount += self.stepCount * self.groupPlayers.count
                        self.ActRef.child("users").child(self.userID).child("NumberOfWorkouts").setValue(self.workoutsCount)
                    }
                    
                    
                }else{
                    // single add for a group
                    // MARK: GROUP Single
                    myGroup.enter()
                    for player in groupPlayers{
                        self.GroupDBRef.child(player).childByAutoId().setValue(exerciseData)
                    }
                    myGroup.leave()
                    myGroup.notify(queue: DispatchQueue.main){
                        let actData = ["time":ServerValue.timestamp(),
                                       "type":"Set Workout",
                                       "message":"You created a group Workout."] as [String:AnyObject]
                        self.ActRef.child("users").child(self.userID).child("activities").childByAutoId().setValue(actData)
                        
                        self.workoutsCount += self.groupPlayers.count
                        self.ActRef.child("users").child(self.userID).child("NumberOfWorkouts").setValue(self.workoutsCount)
                    }
                }
            }else{
                // this is single person add
                // add check for multiple here
                if stepCount > 1{
                    // add loop to add stepcoount times
                    // MARK: SINGLE multiple
                    for _ in 1...stepCount{
                        DBRef.childByAutoId().setValue(exerciseData)
                    }
                    let actData = ["time":ServerValue.timestamp(),
                                   "type":"Set Workout",
                                   "message":"You created \(stepCount) workouts for \(userName!)."] as [String:AnyObject]
                    self.ActRef.child("users").child(self.userID).child("activities").childByAutoId().setValue(actData)
                    workoutsCount += stepCount
                    self.ActRef.child("users").child(userID).child("NumberOfWorkouts").setValue(workoutsCount)
                    
                    
                    
                }else{
                    // just add single time
                    // MARK: SINGLE single
                    DBRef.childByAutoId().setValue(exerciseData)
                    let actData = ["time":ServerValue.timestamp(),
                                   "type":"Set Workout",
                                   "message":"You created a workout for \(userName!)."] as [String:AnyObject]
                    self.ActRef.child("users").child(self.userID).child("activities").childByAutoId().setValue(actData)
                    workoutsCount += 1
                    self.ActRef.child("users").child(userID).child("NumberOfWorkouts").setValue(workoutsCount)
                    
                }
            }
            titleField.text = ""
            AddWorkoutHomeViewController.exercises.removeAll()
            tableview.reloadData()
            
            // new alert
            let alert = SCLAlertView()
            alert.showSuccess("Uploaded", subTitle: "This workout has been uploaded and the player can now view it.", closeButtonTitle: "Ok")
        }
    }


    override func viewDidLoad() {
        
        print(AddWorkoutHomeViewController.groupBool!)
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        
        if !AddWorkoutHomeViewController.groupBool{
            DBRef = Database.database().reference().child("Workouts").child(userName)
        }
        ActRef = Database.database().reference()
        GroupDBRef = Database.database().reference().child("Workouts")
        
        
        self.tableview.layer.cornerRadius = 10
        
        self.navigationItem.title = "Add Workout"
        
        self.tableview.emptyDataSetSource = self
        self.tableview.emptyDataSetDelegate = self
        self.tableview.tableFooterView = UIView()

        
        // setup the stepper
        stepper.wraps = false
        stepper.autorepeat = false
        stepper.minimumValue = 1
        stepper.maximumValue = 4
        stepper.value = 1
        stepper.layer.cornerRadius = 8
        
        // add shadows to the add button
        addButton.layer.shadowColor = UIColor.black.cgColor
        addButton.layer.shadowOffset = CGSize(width: 0, height: 0.0)
        addButton.layer.shadowRadius = 6.0
        addButton.layer.shadowOpacity = 1.0
        addButton.layer.masksToBounds = false
        
        // setup top & bottom view
        let screenSize = view.frame.size
        TopViewHeight.constant = screenSize.height / 6
        topView.layer.cornerRadius = 10
        bottomView.layer.cornerRadius = 10
        shadowView(to: topView)
        shadowView(to: bottomView)
        
        // upload button
        uploadButton.layer.shadowColor = UIColor.black.cgColor
        uploadButton.layer.shadowOffset = CGSize(width: 0, height: 5.0)
        uploadButton.layer.shadowRadius = 5.0
        uploadButton.layer.shadowOpacity = 0.7
        uploadButton.layer.masksToBounds = false
        
        
    }
    
    func shadowView(to view:UIView){
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 5.0)
        view.layer.shadowRadius = 5.0
        view.layer.shadowOpacity = 0.7
        view.layer.masksToBounds = false
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AddWorkoutHomeViewController.exercises.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.text = AddWorkoutHomeViewController.exercises[indexPath.row]["exercise"] as? String
        cell.isUserInteractionEnabled = false
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            AddWorkoutHomeViewController.exercises.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .left)
        }
    }
    
    // emptydataset functions
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = "Add an Exercise"
        let attrs = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .headline)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = "Tap the button in the bottom right to add the first exercise."
        let attrs = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .body)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    func loadNumberOfWorkouts(){
        ActRef.child("users").child(userID).child("NumberOfWorkouts").observeSingleEvent(of: .value) { (snapshot) in
            let count = snapshot.value as? Int ?? 0
            self.workoutsCount = count
        }
    }

    
    override func viewWillAppear(_ animated: Bool) {
        loadNumberOfWorkouts()
        tableview.reloadData()
        navigationController?.navigationBar.tintColor = .white
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

}
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
