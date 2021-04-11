//
//  CoachProfileViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 09/02/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit
import Firebase
import EmptyDataSet_Swift

class CoachProfileViewController: UIViewController, EmptyDataSetSource, EmptyDataSetDelegate{
    
    @IBOutlet weak var profileImage:UIImageView!
    @IBOutlet weak var username:UILabel!
    @IBOutlet weak var fullName:UILabel!
    
    @IBOutlet weak var tableview:UITableView!
    
    @IBOutlet weak var userType:UILabel!
    @IBOutlet weak var followerCount:UIButton!
    @IBOutlet weak var followingCount:UIButton!
    @IBOutlet weak var profileBio:UITextView!
    
    @IBOutlet weak var editBioButton:UIButton!
    @IBOutlet weak var moreInfoButton:UIButton!
    
    @IBOutlet weak var topView:UIView!
    @IBOutlet weak var bottomView:UIView!
    @IBOutlet weak var coveringTopView:UIView!
    
    var posts : [[String:AnyObject]] = []
    
    let userID = Auth.auth().currentUser!.uid
    
    var DBRef:DatabaseReference!
    var PostRef:DatabaseReference!
    
    // array to hold liked posts
    var likedPosts:[String] = []
    
    // tableview class
    var postsTableView:PostTableView!
    

    override func viewDidLoad() {
        super.viewDidLoad()


        self.username.text = "@" + ViewController.username
        
        
        self.tableview.emptyDataSetSource = self
        self.tableview.emptyDataSetDelegate = self
        self.tableview.tableFooterView = UIView()
        
        
        DBRef = Database.database().reference()
        PostRef = Database.database().reference()
        
        editButtons(button: editBioButton)
        //editButtons(button: editPhotoButton)
        editButtons(button: moreInfoButton)
        
        topView.backgroundColor = .white
        
        postsTableView = PostTableView(tableview: tableview, user_ID: userID)
        postsTableView.parent = self
        postsTableView.username = ViewController.username
        postsTableView.tableview.reloadData()
        
        
        
    }
    
    
    // emptydataset functions
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = "No Posts"
        let attrs = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .headline)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = "You have no posts yet."
        let attrs = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .body)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    func loadUserInfo(){
        
        DBRef.child("users").child(self.userID).observe(.value) { (snapshot) in
            if let snap = snapshot.value as? [String:AnyObject]{
                let first = snap["firstName"] as? String
                let last = snap["lastName"] as? String
                self.fullName.text =  first! + " " + last!
                
                if let bio = snap["profileBio"] as? String{
                    self.profileBio.text = bio
                }else{
                    self.profileBio.text = "profile bio..."
                }
                
                if let photoURL = snap["profilePhotoURL"] as? String{
                    let url = URL(string: photoURL)
                    let data = NSData(contentsOf: url!)
                    let image = UIImage(data: data! as Data)
                    DispatchQueue.main.async {
                        self.profileImage.image = image
                        self.profileImage.layer.cornerRadius = self.profileImage.bounds.width / 2.0
                    }
                }else if snap["admin"] as! Bool == true{
                    self.profileImage.image = UIImage(named: "coach_icon")
                }
            
            }
        }
        
    }
    
    
    
    func calculateFollowingCount(){
        
        let followerRef = Database.database().reference().child("Followers").child(userID)
        followerRef.observe(.value) { (snapshot) in
            
            self.followerCount.setTitle(snapshot.childrenCount.description, for: .normal)
            
        }
        
        let followingRef = Database.database().reference().child("Following").child(userID)
        followingRef.observe(.value) { (snapshot) in
            self.followingCount.setTitle(snapshot.childrenCount.description, for: .normal)
        }
    }
    
    @IBAction func showFollowers(_ sender:UIButton){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextVC = storyboard.instantiateViewController(withIdentifier: "FollowersDisplayViewController") as! FollowersDisplayViewController
        nextVC.followers = true
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    @IBAction func showFollowing(_ sender:UIButton){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextVC = storyboard.instantiateViewController(withIdentifier: "FollowersDisplayViewController") as! FollowersDisplayViewController
        nextVC.followers = false
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    
    func editButtons(button:UIButton){
        button.layer.borderWidth = 1
        button.layer.borderColor = Constants.lightColour.cgColor
        button.setTitleColor(Constants.lightColour, for: .normal)
    }
    
    @IBAction func editProfileBio(_ sender:UIButton){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let editPage = storyboard.instantiateViewController(withIdentifier: "EditProfileViewController") as! EditProfileViewController
        if self.profileImage.image != nil{
            editPage.theImage = self.profileImage.image
        }
        editPage.theText = self.profileBio.text
        editPage.modalTransitionStyle = .coverVertical
        editPage.modalPresentationStyle = .fullScreen
        self.navigationController?.present(editPage, animated: true, completion: nil)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)

        
        loadUserInfo()
        calculateFollowingCount()
    }

    

}

