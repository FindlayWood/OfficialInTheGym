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


class AddWorkoutHomeViewController: UIViewController, UITableViewDataSource,UITableViewDelegate, EmptyDataSetSource, EmptyDataSetDelegate, Storyboarded {
    
    weak var coordinator: RegularWorkoutCoordinator?
    
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
    //static var exercises : [WorkoutType] = []
    static var exercises : [[String:Any]] = []
    static var workouts : [[String:Any]] = []
    
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
            
//            var exercisesToUpload : [[String:AnyObject]] = []
//            for ex in AddWorkoutHomeViewController.exercises{
//                exercisesToUpload.append(ex.toObject())
//            }
//
//            print(exercisesToUpload)
            
            let exerciseData = ["title":titleField.text!,
                                "completed":false,
                                "exercises":AddWorkoutHomeViewController.exercises,
                                "createdBy":ViewController.username!,
                                "creatorID":self.userID,
                                "fromDiscover":false,
                                "liveWorkout":false
            ] as [String:AnyObject]

            let createdWorkout = workout(object: exerciseData)
            uploadPage.createdWorkout = createdWorkout
            uploadPage.stepCount = stepCount

            self.navigationController?.pushViewController(uploadPage, animated: true)
            
        }
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
    
    @IBAction func addExercise(_ sender: UIButton) {
        guard let newExercise = exercise() else { return }
        coordinator?.addExercise(newExercise)
//        let vc = BodyTypeViewController.instantiate()
//        navigationController?.pushViewController(vc, animated: true)
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
        //cell.textLabel?.text = AddWorkoutHomeViewController.exercises[indexPath.row].exercise
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
    
    override func viewWillAppear(_ animated: Bool) {
        loadNumberOfWorkouts()
        tableview.reloadData()
        navigationController?.setNavigationBarHidden(false, animated: true)
        let textAttributes = [NSAttributedString.Key.foregroundColor:Constants.lightColour]
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes
        navigationController?.navigationBar.tintColor = Constants.lightColour
    }

}
