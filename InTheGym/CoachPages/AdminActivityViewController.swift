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

class AdminActivityViewController: UIViewController {
    
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
    var PostRef:DatabaseReference!
    
    
    // to display first
    lazy var rowsToDisplay = activities
    
    // queue to order events
    let myGroup = DispatchGroup()
    
    // varibale to check for first time
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    let userID = Auth.auth().currentUser?.uid
    
    // array to hold all players id
    var playersID : [String] = []
    
    // new version of timeline posts
    var posts : [[String:AnyObject]] = []
    var timeline : [[String:AnyObject]] = []
    
    // array to hold likes
    var likedPosts:[String] = []
    
    // class that makes tableview
    var postsTableView:PostTableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        let userID = Auth.auth().currentUser?.uid
        DBRef = Database.database().reference()
        PostRef = Database.database().reference()
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
        
        //loadActivities()
        //loadFeed()
        //loadPlayers()
        
        
        postsTableView = PostTableView(tableview: tableview, userID: userID!, parent: self, username: AdminActivityViewController.username)
        
    }
    
    
    // added for new feed
    @objc fileprivate func handleSegmentChange(){
        switch segment.selectedSegmentIndex {
        case 0:
            //rowsToDisplay = timeline
            postsTableView.rowsToDisplay = postsTableView.timeline
            postsTableView.tableview.reloadData()
            
        default:
            //rowsToDisplay = feed
            postsTableView.rowsToDisplay = postsTableView.playerFeed
            postsTableView.tableview.reloadData()
        }
        //tableview.reloadData()
//        postsTableView = PostTableView(tableview: tableview, posts: rowsToDisplay)
//        postsTableView.tableview.reloadData()
//        postsTableView.observeChanges()
    }
    
    
    @IBAction func writePost(_ sender:UIButton){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let postVC = storyboard.instantiateViewController(withIdentifier: "MakePostViewController") as! MakePostViewController
        postVC.playersID = self.playersID
        postVC.modalTransitionStyle = .coverVertical
        postVC.modalPresentationStyle = .fullScreen
        self.navigationController?.present(postVC, animated: true, completion: nil)
        
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
                self.handleSegmentChange()

            }
            
        }, withCancel: nil)
        
        self.DBRef.child("Public Feed").child(userID!).observeSingleEvent(of: .value) { (snapshot) in
            self.postsTableView = PostTableView(tableview: self.tableview, userID: self.userID!, playerFeed: self.feed)
            self.postsTableView.parent = self
            self.postsTableView.username = AdminActivityViewController.username
            initialLoad = false
        }
    }
    
    func loadPlayers(){
        let playerRef = Database.database().reference().child("CoachPlayers").child(userID!)
        playerRef.observe(.childAdded) { (snapshot) in
            self.playersID.append(snapshot.key)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    

}
