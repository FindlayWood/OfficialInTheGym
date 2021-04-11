//
//  PostsTableview.swift
//  InTheGym
//
//  Created by Findlay Wood on 17/02/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class PostTableView: NSObject, UITableViewDelegate, UITableViewDataSource, workoutTappedDelegate{
    
    var tableview: UITableView!
    var posts: [[String:AnyObject]] = []
    var timeline: [[String:AnyObject]] = []
    var likedPosts : [String] = []
    var PostRef:DatabaseReference!
    var userID = Auth.auth().currentUser!.uid
    var playerFeed: [[String:AnyObject]] = []
    var rowsToDisplay: [[String:AnyObject]] = []
    var topView:UIView?
    var profilePage:Bool?
    var parent:UIViewController!
    var username:String!
    var playerID:String!
    var topViewHeight:CGFloat!
    
    init(tableview:UITableView, user_ID:String) {
        // use this one for already loaded posts, no observers
        self.tableview = tableview
        self.playerID = user_ID
        super.init()
        self.tableview.delegate = self
        self.tableview.dataSource = self
        self.tableview.rowHeight = UITableView.automaticDimension
        self.tableview.estimatedRowHeight = 90
        self.tableview.backgroundColor = Constants.darkColour
        self.tableview.tableFooterView = UIView()
        self.tableview.register(UINib(nibName: "WorkoutCell", bundle: nil), forCellReuseIdentifier: "WorkoutCell")
        self.tableview.register(UINib(nibName: "PostCell", bundle: nil), forCellReuseIdentifier: "PostCell")
        self.tableview.register(UINib(nibName: "ActivityCell", bundle: nil), forCellReuseIdentifier: "ActivityCell")
        self.PostRef = Database.database().reference()
        loadSelfPosts()
        
    }
    
    init(tableview:UITableView, userID:String, parent:UIViewController, username:String) {
        // use this one for timelines
        self.tableview = tableview
        self.userID = userID
        self.parent = parent
        self.username = username
        super.init()
        self.tableview.delegate = self
        self.tableview.dataSource = self
        self.tableview.rowHeight = UITableView.automaticDimension
        self.tableview.estimatedRowHeight = 90
        self.tableview.backgroundColor = Constants.darkColour
        self.tableview.tableFooterView = UIView()
        self.tableview.register(UINib(nibName: "WorkoutCell", bundle: nil), forCellReuseIdentifier: "WorkoutCell")
        self.tableview.register(UINib(nibName: "PostCell", bundle: nil), forCellReuseIdentifier: "PostCell")
        self.tableview.register(UINib(nibName: "ActivityCell", bundle: nil), forCellReuseIdentifier: "ActivityCell")
        self.PostRef = Database.database().reference()
        loadPosts()
        
    }
    
    init(tableview:UITableView, userID:String, playerFeed:[[String:AnyObject]]){
        // admin home page setup
        self.tableview = tableview
        self.userID = userID
        self.playerFeed = playerFeed
        super.init()
        self.tableview.delegate = self
        self.tableview.dataSource = self
        self.tableview.rowHeight = UITableView.automaticDimension
        self.tableview.estimatedRowHeight = 90
        self.tableview.backgroundColor = Constants.darkColour
        self.tableview.tableFooterView = UIView()
        self.tableview.register(UINib(nibName: "WorkoutCell", bundle: nil), forCellReuseIdentifier: "WorkoutCell")
        self.tableview.register(UINib(nibName: "PostCell", bundle: nil), forCellReuseIdentifier: "PostCell")
        self.tableview.register(UINib(nibName: "ActivityCell", bundle: nil), forCellReuseIdentifier: "ActivityCell")
        self.PostRef = Database.database().reference()
        loadPosts()
        
    }
    
    init(tableview:UITableView, userID:String, topView:UIView) {
        // this setup is for myprofile view
        self.tableview = tableview
        self.topView = topView
        self.profilePage = true
        self.playerID = userID
        super.init()
        self.tableview.delegate = self
        self.tableview.dataSource = self
        self.tableview.rowHeight = UITableView.automaticDimension
        self.tableview.estimatedRowHeight = 90
        self.tableview.backgroundColor = Constants.darkColour
        self.tableview.tableFooterView = UIView()
        self.tableview.register(UINib(nibName: "WorkoutCell", bundle: nil), forCellReuseIdentifier: "WorkoutCell")
        self.tableview.register(UINib(nibName: "PostCell", bundle: nil), forCellReuseIdentifier: "PostCell")
        self.tableview.register(UINib(nibName: "ActivityCell", bundle: nil), forCellReuseIdentifier: "ActivityCell")
        self.PostRef = Database.database().reference()
        loadSelfPosts()
        
    }
    
    func classSetUp(){
        self.tableview.delegate = self
        self.tableview.dataSource = self
        self.tableview.rowHeight = UITableView.automaticDimension
        self.tableview.estimatedRowHeight = 90
        self.tableview.backgroundColor = Constants.darkColour
        self.tableview.tableFooterView = UIView()
        self.tableview.register(UINib(nibName: "WorkoutCell", bundle: nil), forCellReuseIdentifier: "WorkoutCell")
        self.tableview.register(UINib(nibName: "PostCell", bundle: nil), forCellReuseIdentifier: "PostCell")
        self.tableview.register(UINib(nibName: "ActivityCell", bundle: nil), forCellReuseIdentifier: "ActivityCell")
        self.PostRef = Database.database().reference()
        
    }
    
    
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
            let cell = self.tableview.dequeueReusableCell(withIdentifier: "PostCell") as! ActivityTableViewCell
            
            let posterID = rowsToDisplay[indexPath.row]["posterID"] as? String
     
            self.PostRef.child("users").child(posterID!).child("profilePhotoURL").observeSingleEvent(of: .value) { (snapshot) in
                if let imageURL = snapshot.value as? String{
                    DispatchQueue.global(qos: .background).async {
                        let url = URL(string: imageURL)
                        let data = NSData(contentsOf: url!)
                        let image = UIImage(data: data! as Data)
                        DispatchQueue.main.async {
                            cell.postProfilePhoto.setImage(image, for: .normal)
                            cell.postProfilePhoto.layer.cornerRadius = cell.postProfilePhoto.bounds.width / 2.0
                        }
                    }
                }else{
                    cell.postProfilePhoto.setImage(UIImage(named: "coach_icon"), for: .normal)
                    
                }
            }
            cell.postTime.text = final
            cell.postUsername.setTitle(rowsToDisplay[indexPath.row]["username"] as? String, for: .normal)
            cell.postText.text = rowsToDisplay[indexPath.row]["message"] as? String
            cell.selectionStyle = .none
            if let replies = rowsToDisplay[indexPath.row]["postReplies"] as? Int{
                cell.postReplyLabel.text = replies.description
                cell.postReplyIcon.isHidden = false
            }else{
                cell.postReplyLabel.text = "0"
                cell.postReplyIcon.isHidden = false
            }
            if let likeCount = rowsToDisplay[indexPath.row]["likeCount"] as? Int{
                cell.postLikeLabel.text = likeCount.description
            }else{
                cell.postLikeLabel.text = "0"
            }
            let likedPostsRef = Database.database().reference().child("Likes").child(userID).child(rowsToDisplay[indexPath.row]["postID"] as! String)
            likedPostsRef.observeSingleEvent(of: .value) { (snapshot) in
                if snapshot.exists(){
                    if #available(iOS 13.0, *) {
                        cell.postLikeButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
                    } else {
                        // Fallback on earlier versions
                    }
                }else{
                    if #available(iOS 13.0, *) {
                        cell.postLikeButton.setImage(UIImage(systemName: "star"), for: .normal)
                    } else {
                        // Fallback on earlier versions
                    }
                }
            }
            
            cell.delegate = self
            cell.indexPath = indexPath
            return cell
        }
        else if rowsToDisplay[indexPath.row]["type"] as? String == "workout"{
            let cell = self.tableview.dequeueReusableCell(withIdentifier: "WorkoutCell") as! ActivityTableViewCell
            
            let posterID = rowsToDisplay[indexPath.row]["posterID"] as? String
     
            self.PostRef.child("users").child(posterID!).child("profilePhotoURL").observeSingleEvent(of: .value) { (snapshot) in
                if let imageURL = snapshot.value as? String{
                    DispatchQueue.global(qos: .background).async {
                        let url = URL(string: imageURL)
                        let data = NSData(contentsOf: url!)
                        let image = UIImage(data: data! as Data)
                        DispatchQueue.main.async {
                            cell.workoutProfilePhoto.setImage(image, for: .normal)
                            cell.workoutProfilePhoto.layer.cornerRadius = cell.workoutProfilePhoto.bounds.width / 2.0
                            //cell.profilePhoto.image = image
                            //cell.profilePhoto.layer.cornerRadius = cell.profilePhoto.bounds.width / 2.0
                        }
                    }
                }else{
                    cell.workoutProfilePhoto.setImage(UIImage(named: "benchpress_icon"), for: .normal)
                    //cell.profilePhoto.image = UIImage(named: "benchpress_icon")
                }
            }
            
            //cell.profilePhoto.image = UIImage(named: "benchpress_icon")
            cell.workoutUsername.setTitle(rowsToDisplay[indexPath.row]["username"] as? String, for: .normal)
            //cell.workoutUsername.text = rowsToDisplay[indexPath.row]["username"] as? String
            cell.workoutPostTime.text = final
            let exerciseData = rowsToDisplay[indexPath.row]["exerciseData"] as! [String:AnyObject]
            cell.exerciseCountLabel.text = "Exercises: \(exerciseData["exercises"]?.count ?? 0)"
            //cell.workoutScore.isHidden = false
            cell.exerciseTimeLabel.isHidden = false
            cell.exerciseTimeIcon.isHidden = false
            //cell.scoreIcon.isHidden = false
            cell.creatorIcon.isHidden = false
            //cell.workoutScore.text = exerciseData["score"] as? String
            cell.exerciseTimeLabel.text = exerciseData["timeToComplete"] as? String
            cell.workoutTitle.text = exerciseData["title"] as? String
            cell.creatorLabel.text = exerciseData["createdBy"] as? String
            cell.createOrComplete.text = "COMPLETED A WORKOUT"
            cell.selectionStyle = .none
            cell.delegate = self
            cell.indexPath = indexPath
            if let replies = rowsToDisplay[indexPath.row]["postReplies"] as? Int{
                cell.workoutReplyLabel.text = replies.description
                cell.workoutReplyIcon.isHidden = false
            }else{
                cell.workoutReplyLabel.text = "0"
                cell.workoutReplyIcon.isHidden = false
            }
            if let likeCount = rowsToDisplay[indexPath.row]["likeCount"] as? Int{
                cell.workoutLikeLabel.text = likeCount.description
            }else{
                cell.workoutLikeLabel.text = "0"
            }
            let likedPostsRef = Database.database().reference().child("Likes").child(userID).child(rowsToDisplay[indexPath.row]["postID"] as! String)
            likedPostsRef.observeSingleEvent(of: .value) { (snapshot) in
                if snapshot.exists(){
                    if #available(iOS 13.0, *) {
                        cell.workoutLikeButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
                    } else {
                        // Fallback on earlier versions
                    }
                }else{
                    if #available(iOS 13.0, *) {
                        cell.workoutLikeButton.setImage(UIImage(systemName: "star"), for: .normal)
                    } else {
                        // Fallback on earlier versions
                    }
                }
            }
            return cell
            
            
        }
        else if rowsToDisplay[indexPath.row]["type"] as? String == "createdNewWorkout"{
            let cell = self.tableview.dequeueReusableCell(withIdentifier: "WorkoutCell") as! ActivityTableViewCell
            let posterID = rowsToDisplay[indexPath.row]["posterID"] as? String
     
            self.PostRef.child("users").child(posterID!).child("profilePhotoURL").observeSingleEvent(of: .value) { (snapshot) in
                if let imageURL = snapshot.value as? String{
                    DispatchQueue.global(qos: .background).async {
                        let url = URL(string: imageURL)
                        let data = NSData(contentsOf: url!)
                        let image = UIImage(data: data! as Data)
                        DispatchQueue.main.async {
                            cell.workoutProfilePhoto.setImage(image, for: .normal)
                            cell.workoutProfilePhoto.layer.cornerRadius = cell.workoutProfilePhoto.bounds.width / 2.0
                            //cell.profilePhoto.image = image
                            //cell.profilePhoto.layer.cornerRadius = cell.profilePhoto.bounds.width / 2.0
                        }
                    }
                }else{
                    cell.workoutProfilePhoto.setImage(UIImage(named: "benchpress_icon"), for: .normal)
                    //cell.profilePhoto.image = UIImage(named: "benchpress_icon")
                }
            }
            
            //cell.profilePhoto.image = UIImage(named: "benchpress_icon")
            cell.workoutUsername.setTitle(rowsToDisplay[indexPath.row]["username"] as? String, for: .normal)
            //cell.username.text = rowsToDisplay[indexPath.row]["username"] as? String
            cell.workoutPostTime.text = final
            let exerciseData = rowsToDisplay[indexPath.row]["exerciseData"] as! [String:AnyObject]
            cell.workoutTitle.text = exerciseData["title"] as? String
            cell.creatorLabel.text = exerciseData["createdBy"] as? String
            cell.exerciseCountLabel.text = "Exercises: \(exerciseData["exercises"]?.count ?? 0)"
            //cell.workoutScore.isHidden = true
            cell.exerciseTimeLabel.isHidden = true
            cell.exerciseTimeIcon.isHidden = true
            //cell.scoreIcon.isHidden = true
            cell.createOrComplete.text = "CREATED A WORKOUT"
            cell.selectionStyle = .none
            cell.delegate = self
            cell.indexPath = indexPath
            if let replies = rowsToDisplay[indexPath.row]["postReplies"] as? Int{
                cell.workoutReplyLabel.text = replies.description
                cell.workoutReplyIcon.isHidden = false
            }else{
                cell.workoutReplyLabel.text = "0"
                cell.workoutReplyIcon.isHidden = false
            }
            if let likeCount = rowsToDisplay[indexPath.row]["likeCount"] as? Int{
                cell.workoutLikeLabel.text = likeCount.description
            }else{
                cell.workoutLikeLabel.text = "0"
            }
            
            let likedPostsRef = Database.database().reference().child("Likes").child(userID).child(rowsToDisplay[indexPath.row]["postID"] as! String)
            likedPostsRef.observeSingleEvent(of: .value) { (snapshot) in
                if snapshot.exists(){
                    if #available(iOS 13.0, *) {
                        cell.workoutLikeButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
                    } else {
                        // Fallback on earlier versions
                    }
                }else{
                    if #available(iOS 13.0, *) {
                        cell.workoutLikeButton.setImage(UIImage(systemName: "star"), for: .normal)
                    } else {
                        // Fallback on earlier versions
                    }
                }
            }
            return cell
        }
        else{
            
            let cell = self.tableview.dequeueReusableCell(withIdentifier: "ActivityCell") as! ActivityTableViewCell
            //tableview.rowHeight = 90
            cell.backgroundColor = .white
            let type = self.rowsToDisplay[indexPath.row]["type"] as? String
            cell.activityType.text = type
            cell.activityTime.text = final
            cell.activityText.text = self.rowsToDisplay[indexPath.row]["message"] as? String
            cell.activityIcon.image = UIImage(named: type!)
            cell.selectionStyle = .none
            return cell

        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if rowsToDisplay[indexPath.row]["type"] as? String == "post" || rowsToDisplay[indexPath.row]["type"] as? String == "workout" || rowsToDisplay[indexPath.row]["type"] as? String == "createdNewWorkout"{
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let discussionVC = storyboard.instantiateViewController(withIdentifier: "DiscussionViewController") as! DiscussionViewController
            discussionVC.originalPost = rowsToDisplay[indexPath.row]
            discussionVC.username = self.username
            discussionVC.likedPosts = self.likedPosts
            self.parent.navigationController?.pushViewController(discussionVC, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if profilePage == true{
            return 93
        }else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if profilePage == true{
            return UIView()
        }else{
            return nil
        }
    }

    func loadFromReferences(from posts:[String]){
        let myGroup = DispatchGroup()
        var initialLoad = true
        var postObjects = [[String:AnyObject]]()
        let postsRef = Database.database().reference().child("Posts")
        for post in posts{
            myGroup.enter()
            postsRef.child(post).observe(.value) { (snapshot) in
                guard var snap = snapshot.value as? [String:AnyObject] else{
                    return
                }
                snap["postID"] = post as AnyObject

                if initialLoad{
                    postObjects.append(snap)
                    myGroup.leave()
                }else{
                    // change has occured and needs to update row of this post index
                    let postIndex = posts.firstIndex(of: post)
                    self.rowsToDisplay[postIndex!] = snap
                    self.tableview.reloadRows(at: [IndexPath(row: postIndex!, section: 0)], with: .none)
                }
            }
        }
        myGroup.notify(queue: .main){
            initialLoad = false
            self.rowsToDisplay = postObjects
            self.tableview.reloadData()
        }
    }
    
    func loadSelfPosts(){
        var initialLoad = true
        var postReferences = [String]()
        let selfPostReferences = Database.database().reference().child("PostSelfReferences").child(playerID)
        selfPostReferences.observe(.childAdded) { (snapshot) in
            postReferences.insert(snapshot.key, at: 0)
            if initialLoad == false{
                // run add new post function
            }
        }
        selfPostReferences.observeSingleEvent(of: .value) { (_) in
            self.loadFromReferences(from: postReferences)
            initialLoad = false
        }
  
    }
    
    
    func loadPosts(){
        var timelinereferences = [String]()
        var initialLoad = true
        let timelineRef = Database.database().reference().child("Timeline").child(self.userID).queryLimited(toLast: 100)
        
        timelineRef.observe(.childAdded) { (snapshot) in
            timelinereferences.insert(snapshot.key, at: 0)
            if initialLoad == false{
                //add new post in
                // show new posts button at top of page
            }
        }
        timelineRef.observeSingleEvent(of: .value) { (_) in
            initialLoad = false
            self.loadTimeLine(with: timelinereferences)
        }
        
    }
    
    func loadTimeLine(with posts:[String]){
        let postRef = Database.database().reference().child("Posts")
        
        let myGroup = DispatchGroup()
        
        var tempPosts = [[String:AnyObject]]()
        
        var initialLoad = true
        
        for post in posts{
            myGroup.enter()
            postRef.child(post).observe(.value) { (snapshot) in
                guard var snap = snapshot.value as? [String:AnyObject] else{
                    return
                }
                snap["postID"] = post as AnyObject
                if initialLoad{
                    tempPosts.append(snap)
                    myGroup.leave()
                }else{
                    let index = posts.firstIndex(of: post)
                    self.rowsToDisplay[index!] = snap
                    self.tableview.reloadRows(at: [IndexPath(row: index!, section: 0)], with: .none)
                }
            }
        }
        myGroup.notify(queue: .main){
            initialLoad = false
            self.rowsToDisplay = tempPosts
            self.tableview.reloadData()
        }
           
    }
    
    func reloadWithNewPosts(){
        // function to add new post to timeline when initial timeline has already been loaded
        let newPost = posts[0]
        let postID = newPost["postID"] as! String
        let posterID = newPost["posterID"] as! String
        let newPostRef = Database.database().reference().child("Posts")
 
        newPostRef.child(posterID).child(postID).observeSingleEvent(of: .value) { (snapshot) in
            var snap = snapshot.value as! [String:AnyObject]
            snap["postID"] = postID as AnyObject
            self.timeline.insert(snap, at: 0)
            self.rowsToDisplay = self.timeline
            self.tableview.reloadData()
        }
    }
    
    func workoutTapped(at index: IndexPath) {
        if rowsToDisplay[index.row]["type"] as! String == "workout"{
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let workoutView = storyboard.instantiateViewController(withIdentifier: "WorkoutDetailViewController") as! WorkoutDetailViewController
            workoutView.fromDiscover = false
            workoutView.liveAdd = false
            let exerciseData = rowsToDisplay[index.row]["exerciseData"] as! [String:AnyObject]
            WorkoutDetailViewController.exercises = exerciseData["exercises"] as! [[String : AnyObject]]
            workoutView.titleString = exerciseData["title"] as! String
            workoutView.username = rowsToDisplay[index.row]["username"] as! String
            workoutView.creatorUsername = exerciseData["createdBy"] as! String
            workoutView.playerID = rowsToDisplay[index.row]["posterID"] as! String
            workoutView.workoutID = rowsToDisplay[index.row]["workoutID"] as! String
            workoutView.complete = true
            self.parent.navigationController?.pushViewController(workoutView, animated: true)
        }else{
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let workoutView = storyboard.instantiateViewController(withIdentifier: "WorkoutDetailViewController") as! WorkoutDetailViewController
            workoutView.fromDiscover = true
            workoutView.liveAdd = false
            let exerciseData = rowsToDisplay[index.row]["exerciseData"] as! [String:AnyObject]
            WorkoutDetailViewController.exercises = exerciseData["exercises"] as! [[String : AnyObject]]
            workoutView.titleString = exerciseData["title"] as! String
            workoutView.username = self.username
            workoutView.playerID = self.userID
            workoutView.creatorUsername = exerciseData["createdBy"] as! String
            workoutView.workoutID = rowsToDisplay[index.row]["workoutID"] as! String
            workoutView.creatorID = rowsToDisplay[index.row]["posterID"] as! String
            self.parent.navigationController?.pushViewController(workoutView, animated: true)
        }
    }
    
    func likeButtonTapped(at index: IndexPath, sender: UIButton) {
        let postID = rowsToDisplay[index.row]["postID"] as? String
        let posterID = rowsToDisplay[index.row]["posterID"] as? String
        let postsRef = Database.database().reference().child("Posts").child(postID!)
        let likeCountRef = Database.database().reference().child("Posts").child(postID!)
        let likedPostsRef = Database.database().reference().child("Likes").child(userID).child(postID!)
        likedPostsRef.observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists(){
                print("already liked this post")
            }else{
                
                likeCountRef.runTransactionBlock { (currentData) -> TransactionResult in
                    if var post = currentData.value as? [String:AnyObject]{
                        var likes = post["likeCount"] as? Int ?? 0
                        likes += 1
                        post["likeCount"] = likes as AnyObject
                        currentData.value = post
                        return TransactionResult.success(withValue: currentData)
                    }
                    return TransactionResult.success(withValue: currentData)
                } andCompletionBlock: { (error, committed, snapshot) in
                    if let error = error{
                        print(error.localizedDescription)
                    }
                }
                
                
                if #available(iOS 13.0, *) {
                    UIView.transition(with: sender, duration: 0.3, options: .transitionCrossDissolve) {
                        sender.setImage(UIImage(systemName: "star.fill"), for: .normal)
                    } completion: { (_) in
//                        if let likeCount = self.rowsToDisplay[index.row]["likeCount"] as? Int{
//                            self.rowsToDisplay[index.row]["likeCount"] = likeCount + 1 as AnyObject
//                            if self.parent is PublicProfileViewController || self.parent is ProfileViewController || self.parent is CoachProfileViewController{
//                                self.tableview.reloadRows(at: [IndexPath(row: index.row, section: 0)], with: .none)
//                            }
//                        }else{
//                            self.rowsToDisplay[index.row]["likeCount"] = 1 as AnyObject
//                            if self.parent is PublicProfileViewController || self.parent is ProfileViewController || self.parent is CoachProfileViewController{
//                                self.tableview.reloadRows(at: [IndexPath(row: index.row, section: 0)], with: .none)
//                            }
//                        }
                    }

                } else {
                    // Fallback on earlier versions
                    print("needs fixing")
                }
                let postLikesRef = Database.database().reference().child("PostLikes").child(postID!)
                let likesRef = Database.database().reference().child("Likes").child(self.userID)
                
                postLikesRef.child(self.userID).setValue(true)
                likesRef.child(postID!).setValue(true)
                if self.userID != posterID!{
                    let notification = NotificationLikedPost(from: self.userID, to: posterID!, postID: postID!)
                    let uploadNotification = NotificationManager(delegate: notification)
                    uploadNotification.upload()
                }

            }
        }
    }
    
    func userTapped(at index:IndexPath) {
        if self.parent is PublicProfileViewController{
            print("shake animation")
        }else{
            // go to public user page
                    let thisUserID = rowsToDisplay[index.row]["posterID"] as! String
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let userPage = storyboard.instantiateViewController(withIdentifier: "PublicProfileViewController") as! PublicProfileViewController

                    let userReference = Database.database().reference().child("users").child(thisUserID)
                    userReference.observeSingleEvent(of: .value) { (snapshot) in
                        if let snap = snapshot.value as? [String:AnyObject]{
                            let thisUser = Users()
                            thisUser.username = snap["username"] as? String
                            thisUser.firstName = snap["firstName"] as? String ?? "no"
                            thisUser.lastName = snap["lastName"] as? String ?? "name"
                            thisUser.admin = snap["admin"] as? Bool ?? false
                            thisUser.uid = thisUserID
                            thisUser.profilePhotoURL = snap["profilePhotoURL"] as? String
                            thisUser.profileBio = snap["profileBio"] as? String
                            userPage.user = thisUser
                            self.parent.navigationController?.pushViewController(userPage, animated: true)
                        }
                    }
        }
        
    }
    
    
    
}
