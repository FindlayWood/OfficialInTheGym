//
//  AdminActivityViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 29/07/2019.
//  Copyright © 2019 FindlayWood. All rights reserved.
//

// added new player feed feature 26/04/20

import UIKit
import Firebase
import SCLAlertView

class AdminActivityViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // outlet to tableview
    @IBOutlet weak var tableview:UITableView!
    
    // trying to switch between
    @IBOutlet weak var segment:UISegmentedControl!
    
    // username of the coach, global variable
    static var username:String = ""
    
    // username of coach local variable
    var localusername:String = ""
    
    // coach activities
    var activities : [[String:AnyObject]] = []
    
    // player activities
    var feed : [[String:AnyObject]] = []
    
    // database references
    var DBRef:DatabaseReference!
    var UserRef:DatabaseReference!
    
    
    // to display first
    lazy var rowsToDisplay = activities
    
    // queue to order events
    let myGroup = DispatchGroup()
    
    // varibale to check for first time
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    let userID = Auth.auth().currentUser?.uid
    
    // array to hold all players id
    var playersID : [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        //self.tableview.rowHeight = 90
        tableview.rowHeight = UITableView.automaticDimension
        tableview.estimatedRowHeight = 90
        tableview.backgroundColor = .white
        tableview.tableFooterView = UIView()
        let userID = Auth.auth().currentUser?.uid
        DBRef = Database.database().reference()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        UserRef = Database.database().reference().child("users").child(userID!)
        UserRef.child("username").observeSingleEvent(of: .value) { (snapshot) in
            AdminActivityViewController.username = snapshot.value as! String
        }
        
        // added for new feed
        segment.addTarget(self, action: #selector(handleSegmentChange), for: .valueChanged)
        let NotSelectedTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 12)]
        let SelectedTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 12)]
        segment.setTitleTextAttributes(NotSelectedTextAttributes, for: .normal)
        segment.setTitleTextAttributes(SelectedTextAttributes, for: .selected)
        
        loadActivities()
        loadFeed()
        loadPlayers()
        
    }
    
    
    // added for new feed
    @objc fileprivate func handleSegmentChange(){
        switch segment.selectedSegmentIndex {
        case 0:
            rowsToDisplay = activities
        default:
            rowsToDisplay = feed
        }
        tableview.reloadData()
    }
    
    
    @IBAction func writePost(_ sender:UIButton){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let postVC = storyboard.instantiateViewController(withIdentifier: "MakePostViewController") as! MakePostViewController
        postVC.playersID = self.playersID
        self.navigationController?.pushViewController(postVC, animated: true)
        
    }
    
    // loading tableview using switch segment
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowsToDisplay.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let dateStamp = self.rowsToDisplay[indexPath.row]["time"] as? TimeInterval
        let date = NSDate(timeIntervalSince1970: dateStamp!/1000)
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        let final = formatter.string(from: date as Date)
        
        if rowsToDisplay[indexPath.row]["type"] as? String == "post"{
            //tableview.rowHeight = 180
            let cell = self.tableview.dequeueReusableCell(withIdentifier: "cell2") as! ActivityTableViewCell
            
            let coachID = rowsToDisplay[indexPath.row]["posterID"] as? String
     
            self.DBRef.child("users").child(coachID!).child("profilePhotoURL").observeSingleEvent(of: .value) { (snapshot) in
                if let imageURL = snapshot.value as? String{
                    DispatchQueue.global(qos: .background).async {
                        let url = URL(string: imageURL)
                        let data = NSData(contentsOf: url!)
                        let image = UIImage(data: data! as Data)
                        DispatchQueue.main.async {
                            cell.profilePhoto.image = image
                            cell.profilePhoto.layer.cornerRadius = cell.profilePhoto.bounds.width / 2.0
                        }
                    }
                }else{
                    cell.profilePhoto.image = UIImage(named: "coach_icon")
                }
            }
            
            cell.postTime.text = final
            cell.username.text = rowsToDisplay[indexPath.row]["username"] as? String
            cell.postText.text = rowsToDisplay[indexPath.row]["message"] as? String
            return cell
        }
        else if rowsToDisplay[indexPath.row]["type"] as? String == "workout"{
            let cell = self.tableview.dequeueReusableCell(withIdentifier: "cell3") as! ActivityTableViewCell
            
            cell.profilePhoto.image = UIImage(named: "benchpress_icon")
            cell.username.text = rowsToDisplay[indexPath.row]["username"] as? String
            cell.postTime.text = final
            cell.workoutExerciseCount.text = rowsToDisplay[indexPath.row]["numberOfExercises"] as? String
            cell.workoutScore.text = rowsToDisplay[indexPath.row]["score"] as? String
            cell.workoutTime.text = rowsToDisplay[indexPath.row]["timeToComplete"] as? String
            cell.workoutTitle.text = rowsToDisplay[indexPath.row]["workoutTitle"] as? String
            
            
            return cell
            
            
        }
        
        
        
        else{
            
            let cell = self.tableview.dequeueReusableCell(withIdentifier: "cell") as! ActivityTableViewCell
            //tableview.rowHeight = 90
            cell.backgroundColor = .white
            let type = self.rowsToDisplay[indexPath.row]["type"] as? String
            cell.type.text = type
            cell.time.text = final
            cell.message.text = self.rowsToDisplay[indexPath.row]["message"] as? String
            cell.pic.image = UIImage(named: type!)
            return cell

        }
        
    }
    
    func loadActivities(){
        //activities.removeAll()
        
        var initialLoad = true
        self.DBRef.child("Activities").child(self.userID!).observe(.childAdded, with: { (snapshot) in
            if let snap = snapshot.value as? [String:AnyObject]{
                self.activities.insert(snap, at: 0)
            }
            
            if initialLoad == false{
                if self.segment.selectedSegmentIndex == 0{
                    self.tableview.reloadData()
                }

            }
 
        }, withCancel: nil)

        self.DBRef.child("Activities").child(self.userID!).observeSingleEvent(of: .value) { [self] (_) in
            self.handleSegmentChange()
            initialLoad = false
            print(activities.count)
            
        }
        
    }

    
    // loading public feed
    func loadFeed(){
        //feed.removeAll()
        var initialLoad = true
        self.DBRef.child("Public Feed").child(userID!).observe(.childAdded, with: { (snapshot) in
            if let snap = snapshot.value as? [String:AnyObject]{
                self.feed.insert(snap, at: 0)
            }
            
            if initialLoad == false{
                if self.segment.selectedSegmentIndex == 1{
                    self.tableview.reloadData()
                }
            }
            
        }, withCancel: nil)
        
        self.DBRef.child("Public Feed").child(userID!).observeSingleEvent(of: .value) { (snapshot) in
            //self.handleSegmentChange()
            initialLoad = false
        }
    }
    
    func loadPlayers(){
        self.playersID.removeAll()
        self.DBRef.child("users").child(userID!).child("players").child("accepted").observe(.childAdded) { (snapshot) in
            if let snap = snapshot.value as? String{
                self.playersID.append(snap)
            }
        }
    }
    
    // display first time message
    override func viewDidAppear(_ animated: Bool) {
         if(!appDelegate.hasAlreadyLaunched){
            //set hasAlreadyLaunched to false
            appDelegate.sethasAlreadyLaunched()
            //display user agreement license
            // get width of screen to adjust alert appearance
            let screenSize: CGRect = UIScreen.main.bounds
            let screenWidth = screenSize.width
            
            let appearance = SCLAlertView.SCLAppearance(
                kWindowWidth: screenWidth - 40 )

            let alert = SCLAlertView(appearance: appearance)
            alert.showInfo("Welcome!", subTitle: "Welcome to InTheGym!, You have signed up as a Coach which means you can add players to your 'team', set them workouts and keep a track of their workouts. This page displays the activity of you and your players in the app. Switch between your feed and the players feed with the button near the top of the screen. You can switch pages using the tab bar at the bottom of the screen. Switch page to find out more about it. The first step would be to add players to your team on the ADDPLAYER page. All your info and the app settings are on the My Info page. Thanks for signing up. Enjoy!", closeButtonTitle: "GOT IT!", colorStyle: 0x347aeb, animationStyle: .bottomToTop)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        loadActivities()
//        loadFeed()
//        loadPlayers()
    }
    
    

}
