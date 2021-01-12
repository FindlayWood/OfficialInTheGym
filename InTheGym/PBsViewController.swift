//
//  PBsViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 08/07/2019.
//  Copyright © 2019 FindlayWood. All rights reserved.
//

import UIKit
import Firebase

class PBsViewController: UIViewController {
    
    @IBOutlet weak var bench1:UITextField!
    @IBOutlet weak var bench3:UITextField!
    @IBOutlet weak var squat1:UITextField!
    @IBOutlet weak var squat3:UITextField!
    @IBOutlet weak var pullUp3:UITextField!
    @IBOutlet weak var pullUpMax:UITextField!
    @IBOutlet weak var deadlift1:UITextField!
    @IBOutlet weak var deadlift3:UITextField!
    @IBOutlet weak var fitness:UITextField!
    
    @IBOutlet weak var saveButton:UIButton!
    @IBOutlet weak var editButton:UIButton!
    
    var username:String = ""
    var DBRef : DatabaseReference!
    var ActRef : DatabaseReference!
    
    //reference to leaderboard
    var LeaderRef:DatabaseReference!
    
    // coach username
    var coachUserName: String = ""
    
    // array of coaches, atm just array of strings
    var coaches = [String]()
    
    var pbArray : [[String:Any]] = []
    var activities : [[String:AnyObject]] = []
    
    @IBAction func editPressed(_ sender:UIButton){
        sender.pulsate()
        bench1.isUserInteractionEnabled = true
        bench3.isUserInteractionEnabled = true
        squat1.isUserInteractionEnabled = true
        squat3.isUserInteractionEnabled = true
        pullUp3.isUserInteractionEnabled = true
        pullUpMax.isUserInteractionEnabled = true
        deadlift1.isUserInteractionEnabled = true
        deadlift3.isUserInteractionEnabled = true
        fitness.isUserInteractionEnabled = true
        editButton.isHidden = true
        saveButton.isHidden = false
    }
    
    @IBAction func savePressed(_ sender:UIButton){
        sender.pulsate()
        uploadActivity()
        let pbData = ["Bench1": bench1.text!,
                      "Bench3": bench3.text!,
                      "Squat1": squat1.text!,
                      "Squat3": squat3.text!,
                      "PullUp3": pullUp3.text!,
                      "PullUpMax": pullUpMax.text!,
                      "Deadlift1": deadlift1.text!,
                      "Deadlift3": deadlift3.text!,
                      "Fitness": fitness.text!]
        
        let uploadData = ["username": username,
                          "PBs": pbData] as [String : Any]
        self.pbArray.append(uploadData)
        
        DBRef.child(username).setValue(pbData)
        
        saveButton.isHidden = true
        editButton.isHidden = false
        
        bench1.isUserInteractionEnabled = false
        bench3.isUserInteractionEnabled = false
        squat1.isUserInteractionEnabled = false
        squat3.isUserInteractionEnabled = false
        pullUp3.isUserInteractionEnabled = false
        pullUpMax.isUserInteractionEnabled = false
        deadlift1.isUserInteractionEnabled = false
        deadlift3.isUserInteractionEnabled = false
        fitness.isUserInteractionEnabled = false
        
    }
    
    
    func uploadActivity(){
        let userID = Auth.auth().currentUser?.uid
        let actData = ["time":ServerValue.timestamp(),
                       "type":"Update PBs",
                       "message":"You updated your PB scores.",
                       "isPrivate" : true] as [String:AnyObject]
        ActRef.child("Activities").child(userID!).childByAutoId().setValue(actData)
        
        // adding to posts and timeline
        let postRef = Database.database().reference().child("Posts").child(userID!).childByAutoId()
        let postKey = postRef.key
        let timeLineRef = Database.database().reference().child("Timeline")
        
        let timeLineData = ["postID" : postKey,
                            "posterID" : userID!]
        
        postRef.setValue(actData)
        timeLineRef.child(userID!).childByAutoId().setValue(timeLineData)
        
        
        
        // added for new feature
        // adding to public feed of coach
        
        let actDataPublic = ["time":ServerValue.timestamp(),
                       "type":"Update PBs",
                       "message":"\(username) updated their PB scores."] as [String:AnyObject]
        
        
        if ViewController.admin == false && coaches.count != 0{
            // using coach userid to add to public feed instead of username
            for coach in coaches{
                self.ActRef.child("Public Feed").child(coach).childByAutoId().setValue(actDataPublic)
                
                let coachPostRef = Database.database().reference().child("Posts").child(coach).childByAutoId()
                let coachPostKey = coachPostRef.key
                let timeLineData = ["postID" : coachPostKey,
                                    "posterID" : coach]
                
                coachPostRef.setValue(actDataPublic)
                timeLineRef.child(coach).childByAutoId().setValue(timeLineData)
                    
    
            }
        }else{
            print("no coaches to upload to.")
        }
        
        
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        saveButton.isHidden = true
        
        //creating database references
        DBRef = Database.database().reference().child("PBs")
        ActRef = Database.database().reference()
        let userID = Auth.auth().currentUser?.uid
        
        if ViewController.admin == false{
            ActRef.child("users").child(userID!).child("coachName").observeSingleEvent(of: .value) { (snapshot) in
                if let snap = snapshot.value as? String{
                    self.coachUserName = snap
                }
                
            }
            ActRef.child("users").child(userID!).child("coaches").observe(.childAdded) { (snapshot) in
                if let snap = snapshot.value as? String{
                    self.coaches.append(snap)
                }
            }
        }
        else{
            editButton.isHidden = true
        }
        
        
        
        DBRef.child(username).observeSingleEvent(of: .value) { (snapshot) in
            if let snap = snapshot.value as? [String : AnyObject]{
                self.bench1.text = snap["Bench1"] as? String
                self.bench3.text = snap["Bench3"] as? String
                self.squat1.text = snap["Squat1"] as? String
                self.squat3.text = snap["Squat3"] as? String
                self.pullUp3.text = snap["PullUp3"] as? String
                self.pullUpMax.text = snap["PullUpMax"] as? String
                self.deadlift1.text = snap["Deadlift1"] as? String
                self.deadlift3.text = snap["Deadlift3"] as? String
                self.fitness.text = snap["Fitness"] as? String
            }
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        let textAttributes = [NSAttributedString.Key.foregroundColor:#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)]
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    }
}
