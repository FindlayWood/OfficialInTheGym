//
//  PlayerActivityViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 30/07/2019.
//  Copyright © 2019 FindlayWood. All rights reserved.
//

//***playerpage***

import UIKit
import Firebase
import SCLAlertView

class PlayerActivityViewController: UIViewController {
    
    @IBOutlet weak var tableview:UITableView!
    
    // players username, coaches username, coach uid
    static var username:String!
    static var coachName:String!
    static var coachID:String!
    
    
    var DBref:DatabaseReference!
    var UserRef:DatabaseReference!
    var PostRef:DatabaseReference!
    
    // varibale to check for first time
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    let userID = Auth.auth().currentUser?.uid
    
    // array of coaches
    var coaches:[String] = []
    
    // tableview class
    var postsTableView: PostTableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableview.rowHeight = UITableView.automaticDimension
        self.tableview.estimatedRowHeight = 90
        self.tableview.tableFooterView = UIView()
        self.tableview.backgroundColor = Constants.darkColour
        
        let userID = Auth.auth().currentUser?.uid
        
        DBref = Database.database().reference().child("Activities").child(userID!)
        UserRef = Database.database().reference().child("users").child(userID!)
//        UserRef.child("username").observeSingleEvent(of: .value) { (snapshot) in
//            PlayerActivityViewController.username = snapshot.value as? String
//            self.postsTableView = PostTableView(tableview: self.tableview, userID: userID!, parent: self, username: PlayerActivityViewController.username)
//        }
        PostRef = Database.database().reference()
        

        loadCoaches()
        
        UserIDToUser.transform(userID: userID!) { (user) in
            self.postsTableView = PostTableView(tableview: self.tableview, userID: userID!, parent: self, username: user.username!)
            PlayerActivityViewController.username = user.username!
        }
        
        LoadFollowers.returnFollowers(for: userID!) { (followers) in
            print(followers)
        }
        

        // add tab bar selection image
//        let tabBar = self.tabBarController!.tabBar
//        tabBar.selectionIndicatorImage = UIImage().createSelectionIndicator(color: Constants.darkColour, size: CGSize(width: tabBar.frame.width/CGFloat(tabBar.items!.count), height: tabBar.frame.height), lineWidth: 2.0)
        
    }
    
    
    @IBAction func writePost(_ sender:UIButton){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let postVC = storyboard.instantiateViewController(withIdentifier: "MakePostViewController") as! MakePostViewController
        postVC.playerCoaches = self.coaches
        postVC.playerPost = true
        postVC.groupBool = false
        postVC.modalTransitionStyle = .coverVertical
        postVC.modalPresentationStyle = .fullScreen
        self.navigationController?.present(postVC, animated: true, completion: nil)
        //self.navigationController?.pushViewController(postVC, animated: true)
        
    }
    
    func loadCoaches(){
        // load array of coaches and set variable equal
        UserRef.child("coaches").observe(.childAdded) { (snapshot) in
            if let snap = snapshot.value as? String{
                self.coaches.append(snap)
            }
        }
    }
    
        
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
}
