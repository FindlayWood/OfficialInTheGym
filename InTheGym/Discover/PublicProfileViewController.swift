//
//  PublicProfileViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 07/01/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit
import Firebase
import EmptyDataSet_Swift

class PublicProfileViewController: UIViewController, EmptyDataSetSource, EmptyDataSetDelegate {
    
    @IBOutlet weak var profileImage:UIImageView!
    @IBOutlet weak var username:UILabel!
    @IBOutlet weak var fullName:UILabel!
    @IBOutlet weak var followButton:UIButton!
    
    @IBOutlet weak var tableview:UITableView!
    
    @IBOutlet weak var userType:UILabel!
    @IBOutlet weak var userTypeButton:UIButton!
    @IBOutlet weak var followerCount:UIButton!
    @IBOutlet weak var followingCount:UIButton!
    @IBOutlet weak var profileBio:UITextView!
    
    var user : Users!
    var posts : [[String:AnyObject]] = []
    
    let userID = Auth.auth().currentUser!.uid
    
    var DBRef:DatabaseReference!
    var PostRef:DatabaseReference!
    
    // array to hold liked posts
    var likedPosts:[String] = []
    
    // class that makes tableview
    var postsTableView:PostTableView!
    
    // self username
    var selfUsername:String!

    override func viewDidLoad() {
        super.viewDidLoad()

        
        username.text = "@" + user.username!
        fullName.text = user.firstName! + " " + user.lastName!
        profileImage.image = UIImage(named: "player_icon")
        
        DBRef = Database.database().reference()
        PostRef = Database.database().reference()
        
        //loadPosts()
        tableview.rowHeight = UITableView.automaticDimension
        tableview.estimatedRowHeight = 90
        tableview.backgroundColor = Constants.darkColour
        
        self.tableview.emptyDataSetSource = self
        self.tableview.emptyDataSetDelegate = self
        self.tableview.tableFooterView = UIView()
        
        //downloadLikes()
        
        self.postsTableView = PostTableView(tableview: self.tableview, user_ID:user.uid!)
        self.postsTableView.parent = self
        if ViewController.admin{
            self.postsTableView.username = AdminActivityViewController.username
        }else{
            self.postsTableView.username = PlayerActivityViewController.username
            
        }
        self.postsTableView.tableview.reloadData()
        
        loadProfilePhoto()
        initUI()
    }
    
    func loadProfilePhoto(){
        if let profileImageURL = user.profilePhotoURL{
            DispatchQueue.global(qos: .background).async {
                let url = URL(string: profileImageURL)
                let data = NSData(contentsOf: url!)
                let image = UIImage(data: data! as Data)
                DispatchQueue.main.async {
                    self.profileImage.image = image
                    self.profileImage.layer.cornerRadius = self.profileImage.bounds.width / 2
                }
            }
        }
    }
    
    func initUI(){
        if user.admin!{
            self.userType.text = "Coach"
            self.userTypeButton.setImage(UIImage(named: "coach_icon"), for: .normal)
        }else{
            self.userType.text = "Player"
            self.userTypeButton.setImage(UIImage(named: "player_icon"), for: .normal)
        }
        self.followerCount.isUserInteractionEnabled = false
        self.followingCount.isUserInteractionEnabled = false
    }
    
    
    @IBAction func follow(_ sender:UIButton){
        
        // add user to following list
        let followingRef = Database.database().reference().child("Following").child(self.userID).childByAutoId()
        followingRef.setValue(user.uid)
        
        // add self to users followers list
        let followersRef = Database.database().reference().child("Followers").child(user.uid!).childByAutoId()
        followersRef.setValue(self.userID)
        
        followButton.setTitle("Following", for: .normal)
        followButton.backgroundColor = .lightGray
        
        
        let postRef = Database.database().reference().child("Posts").child(self.userID).childByAutoId()
        let postKey = postRef.key!
        
        let postData = ["type" : "Following",
                        "message" : "You started following \(user.username!).",
                        "time" : ServerValue.timestamp(),
                        "posterID" : self.userID,
                        "username" : self.selfUsername!] as [String : Any]
        
        let timelineRef = Database.database().reference().child("Timeline").child(self.userID).childByAutoId()
        let timelineData = ["postID" : postKey,
                            "posterID" : self.userID]
        postRef.setValue(postData)
        timelineRef.setValue(timelineData)
        
        displayTopView(with: "You are now following \(user.username!).")
        let notification = NotificationFollowed(from: self.userID, to: user.uid!)
        let uploadNotification = NotificationManager(delegate: notification)
        uploadNotification.upload()
        
        
    }
    
    func checkFollowing(){
        
        let followingRef = Database.database().reference().child("Following").child(self.userID).child(user.uid!)
        followingRef.observe(.value) { (snapshot) in
            if snapshot.exists(){
                self.followButton.setTitle("Following", for: .normal)
                self.followButton.backgroundColor = .lightGray
                self.followButton.isUserInteractionEnabled = false
            }
        }
    }
    
 
    
    // emptydataset functions
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = "No Posts"
        let attrs = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .headline)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = "This user has no public posts."
        let attrs = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .body)]
        return NSAttributedString(string: str, attributes: attrs)
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
            UIView.animate(withDuration: 0.6, delay: 2.8, options: .curveEaseOut) {
                topView.frame = startingPoint
                } completion: { (_) in
                    topView.removeFromSuperview()
            }
        }
    }
    
    func calculateFollowingCount(){
        
        let followerRef = Database.database().reference().child("Followers").child(user.uid!)
        followerRef.observe(.value) { (snapshot) in
            self.followerCount.setTitle(snapshot.childrenCount.description, for: .normal)
        }
        
        let followingRef = Database.database().reference().child("Following").child(user.uid!)
        followingRef.observe(.value) { (snapshot) in
            self.followingCount.setTitle(snapshot.childrenCount.description, for: .normal)
        }
        
        
        
    }

    
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        let textAttributes = [NSAttributedString.Key.foregroundColor:Constants.lightColour]
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes
        self.navigationController?.navigationBar.tintColor = Constants.lightColour
        
        if user.admin!{
            userType.text = "Coach"
        }else{
            userType.text = "Player"
        }
        if let bio = user.profileBio{
            profileBio.text = bio
        }else{
            profileBio.text = " "
        }
        if self.userID == user.uid{
            followButton.isHidden = true
        }
        
        checkFollowing()
        calculateFollowingCount()
        
        if ViewController.admin{
            self.selfUsername = AdminActivityViewController.username
        }else{
            self.selfUsername = PlayerActivityViewController.username
        }
    }
    

}
