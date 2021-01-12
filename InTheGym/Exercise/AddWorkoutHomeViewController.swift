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
import SCLAlertView
import EmptyDataSet_Swift


class AddWorkoutHomeViewController: UIViewController, UITableViewDataSource,UITableViewDelegate, EmptyDataSetSource, EmptyDataSetDelegate {
    
    //outlets to text field and tableview
    @IBOutlet weak var titleField:UITextField!
    @IBOutlet weak var tableview:UITableView!
    
    // username & user id of player
    var userName:String!
    var uid:String!
    
    // database referneces
    var DBRef:DatabaseReference!
    var ActRef:DatabaseReference!
    var GroupDBRef:DatabaseReference!
    
    // number of workouts, to be updated if new one added
    var workoutsCount:Int!
    
    // array of activity feed to be updated, may not need anympre
    var activities:[[String:AnyObject]] = []
    
    // user id of curent user, which will be coach
    // allowing players to add workouts will now mean that this could be the userID of the player
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
    
    // variable to check if a player or coach
    var playerBool:Bool!
        
    
    @IBAction func savePressed(_ sender:UIButton){
        
        
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
            var exerciseData = ["title": titleField.text!,
                                "completed": false,
                                "exercises": AddWorkoutHomeViewController.exercises,
                                "createdBy": username] as [String : Any]
            
            // haptic feedback : successfull upload
            let notificationFeedbackGenerator = UINotificationFeedbackGenerator()
            notificationFeedbackGenerator.prepare()
            
            notificationFeedbackGenerator.notificationOccurred(.success)
            
            
            
            // add to posts for self
            // add to timeline of players and self
            // refernce to coach posts, post key of this reference and player reference to posts
            let postRef = Database.database().reference().child("Posts").child(userID).childByAutoId()
            let postID = postRef.key
            let playerPostRef = Database.database().reference().child("Posts")
            
            // reference to timeline and creation of timeline data for coach
            let timeLineRef = Database.database().reference().child("Timeline")
            let timelineData = ["postID" : postID,
                                "posterID": userID]
            
            
            if playerBool {
                // add workout to self
                let myusername = PlayerActivityViewController.username
                
                for step in 1...stepCount{
                    //print("adding...")
                    //let myID = Auth.auth().currentUser?.uid
                    
                    if stepCount > 1{
                        exerciseData["title"] = self.titleField.text! + " (\(step))"
                    }
                    
                    exerciseData["createdBy"] = myusername

                    let workoutRef = Database.database().reference().child("Workouts").child(self.userID).childByAutoId()
                    workoutRef.setValue(exerciseData)
                    
                    

                }
                let actData = ["time":ServerValue.timestamp(),
                               "type":"Set Workout",
                                "message":"You created a new workout.",
                                "isPrivate" : false] as [String:AnyObject]
                let activityRef = Database.database().reference().child("Activities").child(self.userID).childByAutoId()
                activityRef.setValue(actData)
                                    
                let selfPostRef = Database.database().reference().child("Posts").child(self.userID).childByAutoId()
                let postRefKey = selfPostRef.key
                                    
                let timeLineData = ["postID" : postRefKey,
                                    "posterID" : self.userID]
                                    
                let playerTimeLineRef = Database.database().reference().child("Timeline").child(self.userID).childByAutoId()
                playerTimeLineRef.setValue(timeLineData)
                selfPostRef.setValue(actData)
                
            }
            
            
            
            
            // begin with group check
            else if AddWorkoutHomeViewController.groupBool{
                // this is for a group add
                // then add check for multiple
                if stepCount > 1{
                    // MARK: GROUP Multiple
                    // multiple add for a group
                    // in here add loop to add for stepcount times
                    myGroup.enter()
                    for step in 1...stepCount{
                        exerciseData["title"] = self.titleField.text! + " (\(step))"
                        for player in groupPlayers{
                            self.GroupDBRef.child(player).childByAutoId().setValue(exerciseData)
                        }
                    }
                    myGroup.leave()
                    myGroup.notify(queue: DispatchQueue.main){
                        let actData = ["time":ServerValue.timestamp(),
                                       "type":"Set Workout",
                                       "message":"You created \(self.stepCount) group Workouts."] as [String:AnyObject]
                        self.ActRef.child("Activities").child(self.userID).childByAutoId().setValue(actData)
                        
                        let playerTimeLineData = ["time" : ServerValue.timestamp(),
                                                  "type" : "Set Workout",
                                                  "message" : "\(username) created \(self.stepCount) new workouts for you.",
                                                  "isPrivate" : true] as [String:AnyObject]
                        
                        postRef.setValue(actData)
                        timeLineRef.child(self.userID).childByAutoId().setValue(timelineData)
                        for player in self.groupPlayers{
                            // creating brand new post for each player
                            let postkeyref = playerPostRef.child(player).childByAutoId()
                            let playerPostKey = postkeyref.key
                            
                            let playerPostData = ["postID" : playerPostKey,
                                                      "posterID" : player]
                            postkeyref.setValue(playerTimeLineData)
                            
                            
                            // timeline data for each player, pointing to different post
                            timeLineRef.child(player).childByAutoId().setValue(playerPostData)
                        }
                        
                        //self.ActRef.child("users").child(self.userID).child("activities").childByAutoId().setValue(actData)
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
                        self.ActRef.child("Activities").child(self.userID).childByAutoId().setValue(actData)
                        
                        // post for coach and timeline data for coach
                        postRef.setValue(actData)
                        timeLineRef.child(self.userID).childByAutoId().setValue(timelineData)
                        
                        // post data to send to each player
                        let playerTimeLineData = ["time" : ServerValue.timestamp(),
                                                  "type" : "Set Workout",
                                                  "message" : "\(username) created a new workout for you.",
                                                  "isPrivate" : true] as [String:AnyObject]
                        
                        for player in self.groupPlayers{
                            // create new post for each player
                            let postKeyRef = playerPostRef.child(player).childByAutoId()
                            let playerPostKey = postKeyRef.key
                            
                            // data to post to player
                            let playerPostData = ["postID" : playerPostKey,
                                                  "posterID" : player]
                            
                            // add postdata to posts in database
                            postKeyRef.setValue(playerTimeLineData)
                            
                            // add timelinedata to timeline in database
                            timeLineRef.child(player).childByAutoId().setValue(playerPostData)
                            
                            
                        }
                        
                        
                        
                        //self.ActRef.child("users").child(self.userID).child("activities").childByAutoId().setValue(actData)
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
                    for step in 1...stepCount{
                        exerciseData["title"] = self.titleField.text! + " (\(step))"
                        DBRef.childByAutoId().setValue(exerciseData)
                    }
                    let actData = ["time":ServerValue.timestamp(),
                                   "type":"Set Workout",
                                   "message":"You created \(stepCount) workouts for \(userName!)."] as [String:AnyObject]
                    self.ActRef.child("Activities").child(self.userID).childByAutoId().setValue(actData)
                    //self.ActRef.child("users").child(self.userID).child("activities").childByAutoId().setValue(actData)
                    workoutsCount += stepCount
                    self.ActRef.child("users").child(userID).child("NumberOfWorkouts").setValue(workoutsCount)
                    
                    
                    
                    // adding to posts and timeline
                    postRef.setValue(actData)
                    timeLineRef.child(self.userID).childByAutoId().setValue(timelineData)
                    
                    // post data to send to each player
                    let playerPostData = ["time" : ServerValue.timestamp(),
                                          "type" : "Set Workout",
                                          "message" : "\(username) created \(stepCount) new workouts for you.",
                                          "isPrivate" : true] as [String:AnyObject]
                    
                    // create new post for player
                    let postKeyRef = playerPostRef.child(uid).childByAutoId()
                    let playerPostKey = postKeyRef.key
                    
                    // data to post to player
                    let playerTimeLineData = ["postID" : playerPostKey,
                                              "posterID" : uid]
                    
                    // add postdata to posts in database
                    postKeyRef.setValue(playerPostData)
                    
                    // add timelinedata to timeline in database
                    timeLineRef.child(uid).childByAutoId().setValue(playerTimeLineData)
                    
                    
                    
                    
                }else{
                    // just add single time
                    // MARK: SINGLE single
                    DBRef.childByAutoId().setValue(exerciseData)
                    let actData = ["time":ServerValue.timestamp(),
                                   "type":"Set Workout",
                                   "message":"You created a workout for \(userName!)."] as [String:AnyObject]
                    self.ActRef.child("Activities").child(self.userID).childByAutoId().setValue(actData)
                    //self.ActRef.child("users").child(self.userID).child("activities").childByAutoId().setValue(actData)
                    workoutsCount += 1
                    self.ActRef.child("users").child(userID).child("NumberOfWorkouts").setValue(workoutsCount)
                    
                    
                    // adding to posts and timeline
                    // add to coach posts and timeline
                    postRef.setValue(actData)
                    timeLineRef.child(self.userID).childByAutoId().setValue(timelineData)
                    
                    // post data to send to each player
                    let playerPostData = ["time" : ServerValue.timestamp(),
                                          "type" : "Set Workout",
                                          "message" : "\(username) created a new workout for you.",
                                          "isPrivate" : true] as [String:AnyObject]
                    
                    // create new post for player
                    let postKeyRef = playerPostRef.child(uid).childByAutoId()
                    let playerPostKey = postKeyRef.key
                    
                    // data to post to player
                    let playerTimeLineData = ["postID" : playerPostKey,
                                              "posterID" : uid]
                    
                    // add postdata to posts in database
                    postKeyRef.setValue(playerPostData)
                    
                    // add timelinedata to timeline in database
                    timeLineRef.child(uid).childByAutoId().setValue(playerTimeLineData)
                    
                    
                }
            }
            
            let screenSize = UIScreen.main.bounds
            let width = screenSize.width
            
            let appearance = SCLAlertView.SCLAppearance(kWindowWidth: width - 40)
            
            let alert = SCLAlertView(appearance: appearance)
            alert.addButton("Save") {
                
                // add to saved workouts
                let savedRef = Database.database().reference().child("SavedWorkouts").child(self.userID).childByAutoId()
                let refKey = savedRef.key
                
                savedRef.setValue(exerciseData)
                
                // add to posts
                let postRef = Database.database().reference().child("Posts").child(self.userID).childByAutoId()
                let postID = postRef.key!
                
                // add to timeline
                let timeLineRef = Database.database().reference().child("Timeline")
                let newpost = ["postID": postID,
                               "posterID": self.userID]
                
                let postMessage = "\(username) just created a new workout. Check it out below!"
                
                let postData = ["posterID" : self.userID,
                                "workoutID" : refKey!,
                                "username" : username,
                                "time" : ServerValue.timestamp(),
                                "message" : postMessage,
                                "type" : "createdNewWorkout",
                                "exerciseData" : exerciseData,
                                "isPrivate" : true] as [String : Any]
                
                postRef.setValue(postData)
                timeLineRef.setValue(newpost)
                
            }
            alert.addButton("Save and Post to Timeline") {
                
                // add to saved workouts
                let savedRef = Database.database().reference().child("SavedWorkouts").child(self.userID).childByAutoId()
                let refKey = savedRef.key
                
                // add to discover posts
                let discoverRef = Database.database().reference().child("Discover").child("Workouts").childByAutoId()
                let newDiscoverPost = ["posterID" : self.userID,
                                       "postID" : refKey]
                
                // add to posts
                let postRef = Database.database().reference().child("Posts").child(self.userID).childByAutoId()
                let postID = postRef.key!
                
                // add to timeline
                let timeLineRef = Database.database().reference().child("Timeline")
                let newpost = ["postID": postID,
                               "posterID": self.userID]
                
                let postMessage = "\(username) just created a new workout. Check it out below!"
                
                let postData = ["posterID" : self.userID,
                                "workoutID" : refKey!,
                                "username" : username,
                                "time" : ServerValue.timestamp(),
                                "message" : postMessage,
                                "type" : "createdNewWorkout",
                                "exerciseData" : exerciseData,
                                "isPrivate" : false] as [String : Any]
                
                savedRef.setValue(exerciseData)
                discoverRef.setValue(newDiscoverPost)
                postRef.setValue(postData)
                timeLineRef.setValue(newpost)
                
                
                
            }
            alert.showInfo("Save This Workout?", subTitle: "Would you like to save this workout? If you save it, you can access it at a later date. If you press save and post to timeline, this will save your workout and post it to your timeline, where your followers will be able to see it, and it will make it may appear on the Discover Page for other users to view.", closeButtonTitle: "Neither")
            
            
            
            
            titleField.text = ""
            AddWorkoutHomeViewController.exercises.removeAll()
            tableview.reloadData()
            
            if playerBool{
                displayTopView(with: "Workout Uploaded.")
            }else{
                displayTopView(with: "Workout Uploaded. Players can now view it!")
            }
            
            // new alert
//            let alert = SCLAlertView()
//            alert.showSuccess("Uploaded", subTitle: "This workout has been uploaded and the player can now view it.", closeButtonTitle: "Ok")
        }
    }


    override func viewDidLoad() {
        
        print(AddWorkoutHomeViewController.groupBool!)
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        titleField.delegate = self
        
        if !AddWorkoutHomeViewController.groupBool && !playerBool{
            DBRef = Database.database().reference().child("Workouts").child(uid)
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
        view.layer.borderWidth = 2.0
        view.layer.borderColor = UIColor.black.cgColor
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
    
    @IBAction func helpCounter(_ sender:UIButton){
        let screenSize = UIScreen.main.bounds
        let width = screenSize.width
        
        let appearance = SCLAlertView.SCLAppearance(kWindowWidth: width - 40)
        
        let alert = SCLAlertView(appearance: appearance)
        alert.showInfo("Workout Counter", subTitle: "This is the number of times you want to set this workout. If 1, this workout will appear once on the workout page. If 4, then this workout will be set 4 times. We are working on being able to edit the sets and reps in repeating workouts. The maximum number you can set is 4 at the moment.", closeButtonTitle: "OK!")
    }
    
    // this function displays a custom top view letting user know exercise has been added
    func displayTopView(with message:String){
        let viewHeight = self.view.bounds.height * 0.12
        let viewWidth = self.view.bounds.width
        let startingPoint = CGRect(x: 0, y: -30 - viewHeight, width: viewWidth, height: viewHeight)
        let showingPoint = CGRect(x: 0, y: 50, width: viewWidth, height: viewHeight)
        
        
        let topView = CustomTopView(frame: startingPoint)
        topView.image = UIImage(named: "added_icon")
        topView.message = message
        topView.label.textColor = .white
        topView.backgroundColor = Constants.darkColour
        topView.layer.cornerRadius = 0
        topView.layer.borderColor = Constants.darkColour.cgColor
        self.navigationController?.view.addSubview(topView)
        
        UIView.animate(withDuration: 0.6) {
            topView.frame = showingPoint
        } completion: { (_) in
            UIView.animate(withDuration: 0.6, delay: 1.8, options: .curveEaseOut) {
                topView.frame = startingPoint
                } completion: { (_) in
                    topView.removeFromSuperview()
            }
        }
    }

    
    override func viewWillAppear(_ animated: Bool) {
        loadNumberOfWorkouts()
        tableview.reloadData()
        navigationController?.navigationBar.tintColor = Constants.lightColour
        navigationController?.setNavigationBarHidden(false, animated: true)
        let textAttributes = [NSAttributedString.Key.foregroundColor:Constants.lightColour]
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes
    }

}
extension UIViewController: UITextFieldDelegate {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
