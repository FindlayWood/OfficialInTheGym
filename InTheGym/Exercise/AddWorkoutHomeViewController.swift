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
    var groupID : String!
    let myGroup = DispatchGroup()
    
    // variable to check if a player or coach
    var playerBool:Bool!
    
    // array to hold follower ids
    var followers:[String] = []
    var coaches:[String] = []
    
    @IBAction func savePressed(_ sender:UIButton){
        
        if titleField.text == ""{
            
            // new alert
            let alert = SCLAlertView()
            alert.showWarning("OOPS!", subTitle: "Please enter a title.", closeButtonTitle: "Ok")
            
        }else if AddWorkoutHomeViewController.exercises.count == 0{
            // new alert
            let alert = SCLAlertView()
            alert.showWarning("OOPS!", subTitle: "You must enter at least one exercise. Add exercises by tapping the Add Exercise button.", closeButtonTitle: "Ok")
            
        } else {
            // send to upload workout page
            // need who its for/number of ex
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let uploadPage = storyboard.instantiateViewController(withIdentifier: "CreatedWorkoutUploadViewController") as! CreatedWorkoutUploadViewController
            uploadPage.noOfExercises = AddWorkoutHomeViewController.exercises.count
            uploadPage.workoutTitle = titleField.text
            if AddWorkoutHomeViewController.groupBool == true {
                uploadPage.createdFor = self.groupID
                uploadPage.groupBool = true
            } else if playerBool == true {
                uploadPage.createdFor = self.userID
                uploadPage.groupBool = false
            } else  {
                uploadPage.createdFor = self.uid
                uploadPage.groupBool = false
            }
            self.navigationController?.pushViewController(uploadPage, animated: true)
            
        }
        //else{
//            var username : String = ""
//            if playerBool{
//                username = PlayerActivityViewController.username
//            }else{
//                username = AdminActivityViewController.username
//            }
//
//            let savedReferences = Database.database().reference().child("SavedWorkoutReferences").child(userID)
//            let savedWorkoutRef = Database.database().reference().child("SavedWorkouts").childByAutoId()
//            let savedWorkoutCreatorsRef = Database.database().reference().child("SavedWorkoutCreators").child(userID)
//            let savedID = savedWorkoutRef.key!
//            savedReferences.child(savedID).setValue(true)
//            savedWorkoutCreatorsRef.child(savedID).setValue(true)
//
//            var exerciseData = ["title": titleField.text!,
//                                "completed": false,
//                                "exercises": AddWorkoutHomeViewController.exercises,
//                                "createdBy": username,
//                                "savedID": savedID,
//                                "creatorID": userID] as [String : Any]
//
//            // haptic feedback : successfull upload
//            let notificationFeedbackGenerator = UINotificationFeedbackGenerator()
//            notificationFeedbackGenerator.prepare()
//
//            notificationFeedbackGenerator.notificationOccurred(.success)
//
//
//
//            // add to posts for self
//            // add to timeline of players and self
//            // refernce to coach posts, post key of this reference and player reference to posts
//            let postRef = Database.database().reference().child("Posts").childByAutoId()
//            let postID = postRef.key!
//            let playerPostRef = Database.database().reference().child("Posts").childByAutoId()
//            let playerPostRefKey = playerPostRef.key!
//            let postSelfReferences = Database.database().reference().child("PostSelfReferences")
//
//            // reference to timeline and creation of timeline data for coach
//            let timeLineRef = Database.database().reference().child("Timeline")
//
//
//            if playerBool {
//                // add workout to self
//                let myusername = PlayerActivityViewController.username
//
//                for step in 1...stepCount{
//
//                    if stepCount > 1{
//                        exerciseData["title"] = self.titleField.text! + " (\(step))"
//                    }
//
//                    exerciseData["createdBy"] = myusername
//                    exerciseData["assigned"] = false
//
//                    let workoutRef = Database.database().reference().child("Workouts").child(self.userID).childByAutoId()
//                    workoutRef.setValue(exerciseData)
//
//                }
//                let actData = ["time":ServerValue.timestamp(),
//                               "type":"Set Workout",
//                                "message":"You created a new workout.",
//                                "isPrivate" : true] as [String:AnyObject]
//                let activityRef = Database.database().reference().child("Activities").child(self.userID).childByAutoId()
//                activityRef.setValue(actData)
//
//            }
//
//
//
//
//            // begin with group check
//            // MARK: - GROUP
//            else if AddWorkoutHomeViewController.groupBool{
//
//                for step in 1...stepCount{
//
//                    if stepCount > 1{
//                        exerciseData["title"] = self.titleField.text! + " \(step)"
//                    }
//                    exerciseData["createdBy"] = ViewController.username
//                    exerciseData["assigned"] = true
//                    for player in groupPlayers{
//                        self.GroupDBRef.child(player).childByAutoId().setValue(exerciseData)
//                    }
//                }
//                let actData = ["time":ServerValue.timestamp(),
//                               "type":"Set Workout",
//                               "message":"You created \(self.stepCount) group Workouts.",
//                               "isPrivate":true] as [String:AnyObject]
//                postRef.setValue(actData)
//                postSelfReferences.child(self.userID).child(postID).setValue(true)
//                self.ActRef.child("Activities").child(self.userID).childByAutoId().setValue(actData)
//                let playerTimeLineData = ["time" : ServerValue.timestamp(),
//                                          "type" : "Set Workout",
//                                          "message" : "\(username) created \(self.stepCount) new workouts for you.",
//                                          "isPrivate" : true] as [String:AnyObject]
//                timeLineRef.child(self.userID).child(postID).setValue(true)
//                playerPostRef.setValue(playerTimeLineData)
//                for player in groupPlayers{
//                    timeLineRef.child(player).child(playerPostRefKey).setValue(true)
//                    postSelfReferences.child(player).child(playerPostRefKey).setValue(true)
//                }
//                self.workoutsCount += self.stepCount * self.groupPlayers.count
//                self.ActRef.child("users").child(self.userID).child("NumberOfWorkouts").setValue(self.workoutsCount)
//
//            }else{
//                // MARK: - SINGLE
//                for step in 1...stepCount{
//                    if stepCount > 1{
//                        exerciseData["title"] = self.titleField.text! + " \(step)"
//                    }
//                    exerciseData["createdBy"] = ViewController.username
//                    exerciseData["assigned"] = true
//                    DBRef.childByAutoId().setValue(exerciseData)
//                }
//                let actData = ["time":ServerValue.timestamp(),
//                               "type":"Set Workout",
//                               "message":"You created \(stepCount) workouts for \(userName!).",
//                               "isPrivate":true] as [String:AnyObject]
//                postRef.setValue(actData)
//                postSelfReferences.child(self.userID).child(postID).setValue(true)
//                self.ActRef.child("Activities").child(self.userID).childByAutoId().setValue(actData)
//                workoutsCount += stepCount
//                self.ActRef.child("users").child(userID).child("NumberOfWorkouts").setValue(workoutsCount)
//                timeLineRef.child(self.userID).child(postID).setValue(true)
//                let playerPostData = ["time" : ServerValue.timestamp(),
//                                      "type" : "Set Workout",
//                                      "message" : "\(username) created \(stepCount) new workouts for you.",
//                                      "isPrivate" : true] as [String:AnyObject]
//
//                playerPostRef.setValue(playerPostData)
//                timeLineRef.child(uid).child(playerPostRefKey).setValue(true)
//                postSelfReferences.child(uid).child(playerPostRefKey).setValue(true)
//
//            }
//
//            // save the workout
//            // add to own posts/timeline
//
//
//            let screenSize = UIScreen.main.bounds
//            let width = screenSize.width
//
//            let appearance = SCLAlertView.SCLAppearance(kWindowWidth: width - 40, showCloseButton: false)
//
//            let alert = SCLAlertView(appearance: appearance)
//            alert.addButton("Public") {
//
//                //save workout
//                exerciseData["Views"] = 0
//                exerciseData["NumberOfCompletes"] = 0
//                exerciseData["NumberOfDownloads"] = 0
//                exerciseData["TotalTime"] = 0
//                exerciseData["TotalScore"] = 0
//                exerciseData["isPrivate"] = false
//                exerciseData.removeValue(forKey: "assigned")
//
//                savedWorkoutRef.setValue(exerciseData)
//
//                // add to posts
//                let postSelfReferences = Database.database().reference().child("PostSelfReferences").child(self.userID)
//                let postRef = Database.database().reference().child("Posts").childByAutoId()
//                let postID = postRef.key!
//
//                // add to discover posts
//                let discoverRef = Database.database().reference().child("Discover").child("Workouts")
//                discoverRef.child(savedID).setValue(true)
//
//                // add to timeline
//                let timeLineRef = Database.database().reference().child("Timeline").child(self.userID)
//
//                let postData = ["posterID" : self.userID,
//                                "workoutID" : savedID,
//                                "username" : username,
//                                "time" : ServerValue.timestamp(),
//                                "type" : "createdNewWorkout",
//                                "exerciseData" : exerciseData,
//                                "isPrivate" : false] as [String : Any]
//
//                postRef.setValue(postData)
//                timeLineRef.child(postID).setValue(true)
//                postSelfReferences.child(postID).setValue(true)
//                let followerTimeLine = Database.database().reference().child("Timeline")
//
//                // post to followers timeline
//                for follower in self.followers{
//                    followerTimeLine.child(follower).child(postID).setValue(true)
//                }
//                if self.playerBool{
//                    self.displayTopView(with: "Workout Uploaded.")
//                    for coach in self.coaches{
//                        followerTimeLine.child(coach).child(postID).setValue(true)
//                    }
//                }else{
//                    self.displayTopView(with: "Workout Uploaded. Players can now view it!")
//                }
//
//            }
//            alert.addButton("Private") {
//
//                //save workout
//                exerciseData["NumberOfCompletes"] = 0
//                exerciseData["TotalTime"] = 0
//                exerciseData["TotalScore"] = 0
//                exerciseData["isPrivate"] = true
//                exerciseData.removeValue(forKey: "assigned")
//
//                savedWorkoutRef.setValue(exerciseData)
//
//                // add to posts
//                let postSelfReferences = Database.database().reference().child("PostSelfReferences").child(self.userID)
//                let postRef = Database.database().reference().child("Posts").childByAutoId()
//                let postID = postRef.key!
//
//                // add to timeline
//                let timeLineRef = Database.database().reference().child("Timeline").child(self.userID)
//
//                let postData = ["posterID" : self.userID,
//                                "workoutID" : savedID,
//                                "username" : username,
//                                "time" : ServerValue.timestamp(),
//                                "type" : "createdNewWorkout",
//                                "exerciseData" : exerciseData,
//                                "isPrivate" : true] as [String : Any]
//
//                postRef.setValue(postData)
//                timeLineRef.child(postID).setValue(true)
//                postSelfReferences.child(postID).setValue(true)
//                if self.playerBool{
//                    self.displayTopView(with: "Workout Uploaded.")
//                }else{
//                    self.displayTopView(with: "Workout Uploaded. Players can now view it!")
//                }
//            }
//            alert.showInfo("Public or Private?", subTitle: "Would you like to this workout to be PUBLIC or PRIVATE? A public workout can be viewed by anyone on the app and may appear on the DISCOVER page. A private workout can only be viewed by your followers and coaches and will NOT appear on the DISCOVER page.")
//
//
//
//
//            titleField.text = ""
//            AddWorkoutHomeViewController.exercises.removeAll()
//            tableview.reloadData()
//
//        }
    }


    override func viewDidLoad() {
        
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        titleField.delegate = self
        titleField.tintColor = .white
        
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
        
        loadFollowers()
        
        
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
    
    func loadFollowers(){
        
        LoadFollowers.returnFollowers(for: userID) { (followers) in
            self.followers = followers
        }
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
