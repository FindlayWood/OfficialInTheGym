//
//  CompletedWorkoutViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 02/12/2020.
//  Copyright © 2020 FindlayWood. All rights reserved.
//

import UIKit
import Firebase
//import SCLAlertView

class CompletedWorkoutViewController: UIViewController {
    
    // outlets on the page
    @IBOutlet var averageRPE:UILabel!
    @IBOutlet var workoutRPE:UITextField!
    @IBOutlet var timeLabel:UILabel!
    
    // string to set the average rpe label
    var averageExerciseRPE:String!
    
    // username of player and username of assignedcoach
    var playerUsername:String!
    var assignedCoach:String!
    
    // array of the players coaches
    var coaches:[String] = []
    
    // database references
    var DBRef : DatabaseReference!
    var ActRef : DatabaseReference!
    var ComRef : DatabaseReference!
    var FeedRef : DatabaseReference!
    var CoachAct : DatabaseReference!
    var ScoreRef : DatabaseReference!
    var WorkloadRef : DatabaseReference!
    
    // workout id
    var workoutID:String!
    
    // saved id
    var savedID:String!
    
    // title of workout
    var workoutTitle:String!
    
    // the user id of the player
    var playerID:String!
    
    //number of workouts completed
    var numberCompleted:Int!
    
    // the time to complete the workout passed from previous page
    var timeToComplete:Int = 0
    
    // the time when user presses completed
    var endTime:Double!
    
    // the number of exercises in the workout
    var numberOfExercises:Int!
    
    // the array holding all exercises
    var exercises:[[String:AnyObject]] = []
    
    // to tell how many view controllers to pop back
    
    // variable to say if the workout was from discover
    var fromDiscover:Bool!
    var creatorID:String?
    
    var followers:[String] = []
 

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Summary"
        workoutRPE.layer.borderWidth = 2.0
        workoutRPE.layer.borderColor = Constants.darkColour.cgColor
        workoutRPE.layer.cornerRadius = 10.0
        averageRPE.text = averageExerciseRPE
        workoutRPE.becomeFirstResponder()
        workoutRPE.delegate = self
        workoutRPE.keyboardType = .numberPad
        
        let formatter = DateComponentsFormatter()
        
        if timeToComplete > 3600{
            formatter.allowedUnits = [.hour, .minute]
            formatter.unitsStyle = .abbreviated
        }else{
            formatter.allowedUnits = [.minute, .second]
            formatter.unitsStyle = .abbreviated
        }
        
        let timeString = formatter.string(from: TimeInterval(timeToComplete))
        timeLabel.text = timeString
        
        DBRef = Database.database().reference().child("Workouts").child(playerID)
        ActRef = Database.database().reference().child("Activities").child(playerID)
        ComRef = Database.database().reference().child("users").child(playerID)
        FeedRef = Database.database().reference().child("Public Feed")
        CoachAct = Database.database().reference().child("Activities")
        ScoreRef = Database.database().reference().child("Scores")
        WorkloadRef = Database.database().reference().child("Workloads").child(playerID)
        
        let userID = Auth.auth().currentUser?.uid
        LoadFollowers.returnFollowers(for: userID!) { (followers) in
            self.followers = followers
        }
    }
    
    
    @IBAction func upload(_ sender:UIButton){
        if workoutRPE.text == ""{
            showError()
        }else if Int(workoutRPE.text!)! > 10 || Int(workoutRPE.text!)! < 1{
            showError()
        }else{
            if fromDiscover == true{
                //do function to update stats for the public workout
                updateDiscoverWorkoutStats(with: Int(workoutRPE.text!)!)
            }
            // haptic feedback : complete workout
            let notificationFeedbackGenerator = UINotificationFeedbackGenerator()
            notificationFeedbackGenerator.prepare()
            notificationFeedbackGenerator.notificationOccurred(.success)
            self.DBRef.child("\(self.workoutID!)").updateChildValues(["completed" : true])
            //self.DBRef.child(self.workoutID).updateChildValues(["liveWorkout" : false])
            let scoreNum = workoutRPE.text!
            self.DBRef.child("\(self.workoutID!)").updateChildValues(["score" : scoreNum])
            let actData = ["time":ServerValue.timestamp(),
                           "message":"You completed the workout \(self.workoutTitle!).",
                            "type":"Workout Completed"] as [String:AnyObject]

            self.ActRef.childByAutoId().setValue(actData)
            self.numberCompleted += 1
            self.ComRef.updateChildValues(["numberOfCompletes":self.numberCompleted!])
            let actData2 = ["time":ServerValue.timestamp(),
                            "message":"\(self.playerUsername!) completed the workout \(self.workoutTitle!).",
                            "type":"Workout Completed"] as [String:AnyObject]
                

            let scoreInfo = [self.workoutTitle:scoreNum]
// MARK: new section for looping coaches, adding activity and scores
            for coach in self.coaches{
                    
                // loop all coaches and add activity to public feed

                self.FeedRef.child(coach).childByAutoId().setValue(actData2)

            }
// end of new section
                
                
            // newest section
            // only a player can complete a workout therefor a coach can never get to this section.
            // this is where the crash occured in version 2 when completing a GROUP workout.
            // version 2.1 resolves this issue
            // 22/1/21 changing from username to userID
            // means that workout now must contain creatorID which can be used instead of assignedCoach
            // then this brings up the point whether a public workout should do this?
            // separate section in scores child - created or a new child completley
            // commented out line below until this issue is resolved.
            // when a workout is created it needs a variable called creatorID
            //self.ScoreRef.child(self.assignedCoach).childByAutoId().setValue(scoreInfo)
            
            // TODO: if from discover and not your own workout = workout from coach therefor update his scores by using creator id
            
            self.ScoreRef.child(self.playerID).childByAutoId().setValue(scoreInfo)
            
            // uploading to database : time to complete and workload
            self.DBRef.child(self.workoutID).updateChildValues(["timeToComplete":timeToComplete])
            let workload = (timeToComplete/60) * Int(scoreNum)!
            self.DBRef.child(self.workoutID).updateChildValues(["workload":workload])
            let workloadData = ["timeToComplete": timeToComplete,
                                "rpe": scoreNum,
                                "endTime": endTime!,
                                "workload": workload,
                                "workoutID": self.workoutID!] as [String : Any]
            self.WorkloadRef.childByAutoId().updateChildValues(workloadData)
            workoutRPE.resignFirstResponder()
            
            
            // in here we will create a post that will be sent to all coaches and the player. coaches can then interact with this post
            // in the future this will be shown to all followers and allow players to copy this workout for themselfs
            
            let postRef = Database.database().reference().child("Posts").childByAutoId()
            let postID = postRef.key!
            
            let timeLineRef = Database.database().reference().child("Timeline")
            
            let formatter = DateComponentsFormatter()
            
            if timeToComplete > 3600{
                formatter.allowedUnits = [.hour, .minute]
                formatter.unitsStyle = .abbreviated
            }else{
                formatter.allowedUnits = [.minute, .second]
                formatter.unitsStyle = .abbreviated
            }
            
            let timeString = formatter.string(from: TimeInterval(timeToComplete))
            
            let exerciseData = ["title":self.workoutTitle!,
                                "completed":true,
                                "createdBy":assignedCoach!,
                                "exercises":self.exercises,
                                "score":scoreNum,
                                "timeToComplete":timeString!,
                                "savedID":savedID!] as [String : Any]
            
            let postData = ["type": "workout",
                            "posterID": playerID!,
                            "workoutID": workoutID!,
                            "username": playerUsername!,
                            "time": ServerValue.timestamp(),
                            "isPrivate" : false,
                            "exerciseData":exerciseData] as [String : Any]
            
            postRef.setValue(postData)
            timeLineRef.child(playerID!).child(postID).setValue(true)
            for coach in self.coaches{
                timeLineRef.child(coach).child(postID).setValue(true)
            }
            for follower in followers{
                timeLineRef.child(follower).child(postID).setValue(true)
            }
            
            
            
            let showView = UIView()
            showView.backgroundColor = .white
            self.view.addSubview(showView)
            showView.frame = view.frame
            let label = UILabel()
            label.text = "Great Work!"
            label.font = UIFont(name: "Menlo-Bold", size: 25)
            label.textColor = .black
            showView.addSubview(label)
            label.translatesAutoresizingMaskIntoConstraints = false
            label.centerXAnchor.constraint(equalTo: showView.centerXAnchor).isActive = true
            label.centerYAnchor.constraint(equalTo: showView.centerYAnchor).isActive = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                showView.removeFromSuperview()
                let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
                self.navigationController?.popToViewController(viewControllers[viewControllers.count - 3], animated: true)
            }

            
            
        }
    }
    
    func updateDiscoverWorkoutStats(with workoutRPE:Int){
        // this function does three things
        // updates number of completes
        // updates number of total rpe score
        // updates number of total time
        
        let completedRef = Database.database().reference().child("SavedWorkouts").child(savedID)
        
        completedRef.runTransactionBlock { (currentData) -> TransactionResult in
            if var post = currentData.value as? [String:AnyObject]{
                var completes = post["NumberOfCompletes"] as? Int ?? 0
                var totalScore = post["TotalScore"] as? Int ?? 0
                var totalTime = post["TotalTime"] as? Int ?? 0
                completes += 1
                totalScore += workoutRPE
                totalTime += self.timeToComplete
                post["NumberOfCompletes"] = completes as AnyObject
                post["TotalScore"] = totalScore as AnyObject
                post["TotalTime"] = totalTime as AnyObject
                currentData.value = post
                return TransactionResult.success(withValue: currentData)
            }
            return TransactionResult.success(withValue: currentData)
        } andCompletionBlock: { (error, committed, snapshot) in
            if let error = error{
                print(error.localizedDescription)
            }
        }

    }
    
    func showError(){
//        let alert = SCLAlertView()
//        alert.showError("Enter Workout RPE", subTitle: "Enter a score between 1 and 10 to complete the workout.")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        let textAttributes = [NSAttributedString.Key.foregroundColor: Constants.lightColour]
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes
        self.navigationController?.navigationBar.tintColor = Constants.lightColour
    }


}
