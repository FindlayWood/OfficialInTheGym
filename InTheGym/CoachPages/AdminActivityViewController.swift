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
    var ActRef:DatabaseReference!
    var UserRef:DatabaseReference!
    
    
    // to display first
    lazy var rowsToDisplay = activities
    
    // queue to order events
    let myGroup = DispatchGroup()
    
    // varibale to check for first time
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    let userID = Auth.auth().currentUser?.uid

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableview.rowHeight = 90
        tableview.backgroundColor = .white
        let userID = Auth.auth().currentUser?.uid
        ActRef = Database.database().reference().child("users").child(userID!).child("activities")
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
    
    override func viewWillAppear(_ animated: Bool) {
        loadActivities()
        loadFeed()
    }
    
    // loading tableview using switch segment
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowsToDisplay.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableview.dequeueReusableCell(withIdentifier: "cell") as! ActivityTableViewCell
        cell.backgroundColor = .white
        let dateStamp = self.rowsToDisplay[indexPath.row]["time"] as? TimeInterval
        let date = NSDate(timeIntervalSince1970: dateStamp!/1000)
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        let final = formatter.string(from: date as Date)
        let type = self.rowsToDisplay[indexPath.row]["type"] as? String
        cell.type.text = type
        cell.time.text = final
        cell.message.text = self.rowsToDisplay[indexPath.row]["message"] as? String
        cell.pic.image = UIImage(named: type!)
        
        return cell
    }
    
    func loadActivities(){
        activities.removeAll()
        self.ActRef.observe(.childAdded, with: { (snapshot) in
            if let snap = snapshot.value as? [String:AnyObject]{
                self.activities.insert(snap, at: 0)
            }
 
        }, withCancel: nil)

        self.ActRef.observeSingleEvent(of: .value) { (_) in
            self.handleSegmentChange()
        }
        
    }

    
    // loading public feed
    func loadFeed(){
        feed.removeAll()
        self.DBRef.child("Public Feed").child(userID!).observe(.childAdded, with: { (snapshot) in
            if let snap = snapshot.value as? [String:AnyObject]{
                self.feed.insert(snap, at: 0)
            }
            
        }, withCancel: nil)
        
        self.DBRef.child("Public Feed").child(userID!).observeSingleEvent(of: .value) { (snapshot) in
            self.handleSegmentChange()
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
    

}
