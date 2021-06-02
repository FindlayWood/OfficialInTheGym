//
//  DiscussionViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 23/01/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit
import Firebase


class DiscussionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, workoutTappedDelegate {
    
    @IBOutlet weak var tableview:UITableView!
    
    var DBRef:DatabaseReference!
    
    var replies:[[String:AnyObject]] = []
    var originalPost:[String:AnyObject]!
    
    var username:String!
    
    // user id
    let userID = Auth.auth().currentUser?.uid
    
    // array to hold liked posts
    var likedPosts:[String] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        tableview.delegate = self
        tableview.dataSource = self
        
        DBRef = Database.database().reference()
        loadReplies()
        tableview.reloadData()
        tableview.tableFooterView = UIView()
        navigationItem.title = "Discussion"
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return replies.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let dateStamp = self.originalPost["time"] as? TimeInterval
        let date = NSDate(timeIntervalSince1970: dateStamp!/1000)
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        let final = formatter.string(from: date as Date)
        
        
        
        if indexPath.row == 0{
            
            if self.originalPost["type"] as! String == "post"{
                
                let cell = tableview.dequeueReusableCell(withIdentifier: "cell") as! DiscussionTableViewCell
                cell.message.text = originalPost["message"] as? String
                cell.time.text = final
                cell.username.text = originalPost["username"] as? String
                let posterID = originalPost["posterID"] as? String
                self.DBRef.child("users").child(posterID!).child("profilePhotoURL").observeSingleEvent(of: .value) { (snapshot) in
                    
                    if let imageURL = snapshot.value as? String{
                        DispatchQueue.global(qos: .background).async {
                            let url = URL(string: imageURL)
                            let data = NSData(contentsOf: url!)
                            let image = UIImage(data: data! as Data)
                            DispatchQueue.main.async {
                                cell.profileImage.image = image
                                cell.profileImage.layer.cornerRadius = cell.profileImage.bounds.width / 2.0
                            }
                        }
                    }else{
                        cell.profileImage.image = UIImage(named: "coach_icon")
                    }
                    
                }
                cell.replyButton.addTarget(self, action: #selector(addReply), for: .touchUpInside)
                if let replyCount = originalPost["postReplies"] as? Int{
                    cell.replyIcon.isHidden = false
                    cell.replyLabel.text = replyCount.description
                }else{
                    cell.replyIcon.isHidden = false
                    cell.replyLabel.text = 0.description
                }
                cell.selectionStyle = .none
                cell.delegate = self
                cell.indexPath = indexPath
                if let likeCount = originalPost["likeCount"] as? Int{
                    cell.likeLabel.text = likeCount.description
                }else{
                    cell.likeLabel.text = "0"
                }
                
                let likedPostsRef = Database.database().reference().child("Likes").child(self.userID!).child(originalPost["postID"] as! String)
                likedPostsRef.observeSingleEvent(of: .value) { (snapshot) in
                    if snapshot.exists(){
                        if #available(iOS 13.0, *) {
                            cell.likeButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
                        } else {
                            // Fallback on earlier versions
                        }
                    }else{
                        if #available(iOS 13.0, *) {
                            cell.likeButton.setImage(UIImage(systemName: "star"), for: .normal)
                        } else {
                            // Fallback on earlier versions
                        }
                    }
                }
                
//                if likedPosts.contains(originalPost["postID"] as! String){
//                    if #available(iOS 13.0, *) {
//                        cell.likeButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
//                    } else {
//                        // Fallback on earlier versions
//                    }
//                }else{
//                    if #available(iOS 13.0, *) {
//                        cell.likeButton.setImage(UIImage(systemName: "star"), for: .normal)
//                    } else {
//                        // Fallback on earlier versions
//                    }
//                }
               
                return cell
                
                
            }else if originalPost["type"] as! String == "workout"{
                
                let cell = tableview.dequeueReusableCell(withIdentifier: "cell3") as! DiscussionTableViewCell
                cell.username.text = originalPost["username"] as? String
                cell.time.text = final
                //cell.workoutExerciseCount.text = timeline[indexPath.row]["numberOfExercises"] as? String
                let exerciseData = originalPost["exerciseData"] as! [String:AnyObject]
                cell.workoutExerciseCount.text = "Exercises: \(exerciseData["exercises"]?.count ?? 0)"
                cell.creatorIcon.isHidden = false
                cell.creatorLabel.isHidden = false
                cell.creatorLabel.text = exerciseData["createdBy"] as? String
                //cell.workoutScore.isHidden = false
                cell.workoutTime.isHidden = false
                cell.timeIcon.isHidden = false
                //cell.scoreIcon.isHidden = false
                //cell.workoutScore.text = exerciseData["score"] as? String
                cell.workoutTime.text = exerciseData["timeToComplete"] as? String
                cell.workoutTitle.text = exerciseData["title"] as? String
                cell.createOrComplete.text = "COMPLETED A WORKOUT"
                let posterID = originalPost["posterID"] as? String
                self.DBRef.child("users").child(posterID!).child("profilePhotoURL").observeSingleEvent(of: .value) { (snapshot) in
                    
                    if let imageURL = snapshot.value as? String{
                        DispatchQueue.global(qos: .background).async {
                            let url = URL(string: imageURL)
                            let data = NSData(contentsOf: url!)
                            let image = UIImage(data: data! as Data)
                            DispatchQueue.main.async {
                                cell.profileImage.image = image
                                cell.profileImage.layer.cornerRadius = cell.profileImage.bounds.width / 2.0
                            }
                        }
                    }else{
                        cell.profileImage.image = UIImage(named: "coach_icon")
                    }
                    
                }
                cell.replyButton.addTarget(self, action: #selector(addReply), for: .touchUpInside)
                if let replyCount = originalPost["postReplies"] as? Int{
                    cell.replyIcon.isHidden = false
                    cell.replyLabel.text = replyCount.description
                }else{
                    cell.replyIcon.isHidden = false
                    cell.replyLabel.text = 0.description
                }
                cell.selectionStyle = .none
                cell.delegate = self
                cell.indexPath = indexPath
                if let likeCount = originalPost["likeCount"] as? Int{
                    cell.likeLabel.text = likeCount.description
                }else{
                    cell.likeLabel.text = "0"
                }
                
                let likedPostsRef = Database.database().reference().child("Likes").child(self.userID!).child(originalPost["postID"] as! String)
                likedPostsRef.observeSingleEvent(of: .value) { (snapshot) in
                    if snapshot.exists(){
                        if #available(iOS 13.0, *) {
                            cell.likeButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
                        } else {
                            // Fallback on earlier versions
                        }
                    }else{
                        if #available(iOS 13.0, *) {
                            cell.likeButton.setImage(UIImage(systemName: "star"), for: .normal)
                        } else {
                            // Fallback on earlier versions
                        }
                    }
                }
                
//                if likedPosts.contains(originalPost["postID"] as! String){
//                    if #available(iOS 13.0, *) {
//                        cell.likeButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
//                    } else {
//                        // Fallback on earlier versions
//                    }
//                }else{
//                    if #available(iOS 13.0, *) {
//                        cell.likeButton.setImage(UIImage(systemName: "star"), for: .normal)
//                    } else {
//                        // Fallback on earlier versions
//                    }
//                }
                
                return cell
                
            }else{
                let cell = tableview.dequeueReusableCell(withIdentifier: "cell3") as! DiscussionTableViewCell
                cell.username.text = originalPost["username"] as? String
                cell.time.text = final
                let exerciseData = originalPost["exerciseData"] as! [String:AnyObject]
                cell.workoutTitle.text = exerciseData["title"] as? String
                cell.workoutExerciseCount.text = "Exercises: \(exerciseData["exercises"]?.count ?? 0)"
                cell.creatorIcon.isHidden = false
                cell.creatorLabel.isHidden = false
                cell.creatorLabel.text = exerciseData["createdBy"] as? String
                //cell.workoutScore.isHidden = true
                cell.workoutTime.isHidden = true
                cell.timeIcon.isHidden = true
                //cell.scoreIcon.isHidden = true
                cell.createOrComplete.text = "CREATED A WORKOUT"
                let posterID = originalPost["posterID"] as? String
                self.DBRef.child("users").child(posterID!).child("profilePhotoURL").observeSingleEvent(of: .value) { (snapshot) in
                    
                    if let imageURL = snapshot.value as? String{
                        DispatchQueue.global(qos: .background).async {
                            let url = URL(string: imageURL)
                            let data = NSData(contentsOf: url!)
                            let image = UIImage(data: data! as Data)
                            DispatchQueue.main.async {
                                cell.profileImage.image = image
                                cell.profileImage.layer.cornerRadius = cell.profileImage.bounds.width / 2.0
                            }
                        }
                    }else{
                        cell.profileImage.image = UIImage(named: "coach_icon")
                    }
                    
                }
                cell.replyButton.addTarget(self, action: #selector(addReply), for: .touchUpInside)
                if let replyCount = originalPost["postReplies"] as? Int{
                    cell.replyIcon.isHidden = false
                    cell.replyLabel.text = replyCount.description
                }else{
                    cell.replyIcon.isHidden = false
                    cell.replyLabel.text = 0.description
                }
                cell.selectionStyle = .none
                cell.delegate = self
                cell.indexPath = indexPath
                if let likeCount = originalPost["likeCount"] as? Int{
                    cell.likeLabel.text = likeCount.description
                }else{
                    cell.likeLabel.text = "0"
                }
                
                let likedPostsRef = Database.database().reference().child("Likes").child(self.userID!).child(originalPost["postID"] as! String)
                likedPostsRef.observeSingleEvent(of: .value) { (snapshot) in
                    if snapshot.exists(){
                        if #available(iOS 13.0, *) {
                            cell.likeButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
                        } else {
                            // Fallback on earlier versions
                        }
                    }else{
                        if #available(iOS 13.0, *) {
                            cell.likeButton.setImage(UIImage(systemName: "star"), for: .normal)
                        } else {
                            // Fallback on earlier versions
                        }
                    }
                }
                
//                if likedPosts.contains(originalPost["postID"] as! String){
//                    if #available(iOS 13.0, *) {
//                        cell.likeButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
//                    } else {
//                        // Fallback on earlier versions
//                    }
//                }else{
//                    if #available(iOS 13.0, *) {
//                        cell.likeButton.setImage(UIImage(systemName: "star"), for: .normal)
//                    } else {
//                        // Fallback on earlier versions
//                    }
//                }
              
                return cell
            }
            

            
            
            
            
            
            
        }else{
            
            let dateStamp = self.replies[indexPath.row - 1]["time"] as? TimeInterval
            let date = NSDate(timeIntervalSince1970: dateStamp!/1000)
            let formatter = DateFormatter()
            formatter.dateStyle = .long
            formatter.timeStyle = .short
            let final = formatter.string(from: date as Date)
            
            
            let cell = tableview.dequeueReusableCell(withIdentifier: "cell2") as! DiscussionTableViewCell
            cell.username.text = replies[indexPath.row - 1]["username"] as? String
            cell.time.text = final
            cell.message.text = replies[indexPath.row - 1]["message"] as? String
            let posterID = replies[indexPath.row - 1]["posterID"] as? String
            
            
            self.DBRef.child("users").child(posterID!).child("profilePhotoURL").observeSingleEvent(of: .value) { (snapshot) in
                
                if let imageURL = snapshot.value as? String{
                    DispatchQueue.global(qos: .background).async {
                        let url = URL(string: imageURL)
                        let data = NSData(contentsOf: url!)
                        let image = UIImage(data: data! as Data)
                        DispatchQueue.main.async {
                            cell.profileImage.image = image
                            cell.profileImage.layer.cornerRadius = cell.profileImage.bounds.width / 2.0
                        }
                    }
                }else{
                    cell.profileImage.image = UIImage(named: "coach_icon")
                }
                
            }
            cell.selectionStyle = .none
            return cell
        }
    }
    
    func loadReplies(){
        
        let postID = originalPost["postID"] as! String
        let posterID = originalPost["posterID"] as! String
        var initialLoad = true
        let replyRef = Database.database().reference().child("PostReplies").child(posterID).child(postID)
        replyRef.observe(.childAdded) { (snapshot) in
            if let snap = snapshot.value as? [String:AnyObject]{
                self.replies.append(snap)
            }
            if initialLoad == false{
                self.tableview.reloadData()
            }
        }
        replyRef.observeSingleEvent(of: .value) { (_) in
            self.tableview.reloadData()
            initialLoad = false
        }
    }
    
    @objc func addReply(){
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let replyPage = storyboard.instantiateViewController(withIdentifier: "ReplyViewController") as! ReplyViewController
        replyPage.postID = originalPost["postID"] as? String
        replyPage.posterID = originalPost["posterID"] as? String
        replyPage.username = self.username
        replyPage.modalTransitionStyle = .coverVertical
        replyPage.modalPresentationStyle = .fullScreen
        navigationController?.present(replyPage, animated: true, completion: nil)
           
    }
    
    func likeButtonTapped(at index: IndexPath, sender: UIButton) {
        let postID = originalPost["postID"] as? String
        let posterID = originalPost["posterID"] as? String
        let postsRef = Database.database().reference().child("Posts").child(posterID!).child(postID!)
        var likeCount:Int!
        let likeCountRef = Database.database().reference().child("Posts").child(posterID!).child(postID!)
        
        let likedthispostref = Database.database().reference().child("Likes").child(self.userID!).child(postID!)
        likedthispostref.observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists(){
                print("already liked")
            }else{
                
                likeCountRef.child("likeCount").observeSingleEvent(of: .value) { (snapshot) in
                    if let snap = snapshot.value as? Int{
                        likeCount = snap + 1
                    }else{
                        likeCount = 1
                    }
                    postsRef.updateChildValues(["likeCount":likeCount!])
                }
                
                
                if #available(iOS 13.0, *) {
                    UIView.transition(with: sender, duration: 0.3, options: .transitionCrossDissolve) {
                        sender.setImage(UIImage(systemName: "star.fill"), for: .normal)
                    } completion: { (_) in
                        if let likeCount = self.originalPost["likeCount"] as? Int{
                            self.originalPost["likeCount"] = likeCount + 1 as AnyObject
                        }else{
                            self.originalPost["likeCount"] = 1 as AnyObject
                        }
                    }

                } else {
                    // Fallback on earlier versions
                    print("needs fixing")
                }
                let postLikesRef = Database.database().reference().child("PostLikes").child(posterID!).child(postID!)
                let likesRef = Database.database().reference().child("Likes").child(self.userID!)
                
                postLikesRef.child(self.userID!).setValue(true)
                likesRef.child(postID!).setValue(true)
                let notification = NotificationLikedPost(from: self.userID!, to: posterID!, postID: postID!)
                let uploadNotification = NotificationManager(delegate: notification)
                uploadNotification.upload { _ in
                    
                }
   
            }
        }
        

    }
    
    func workoutTapped(at index: IndexPath) {
        if originalPost["type"] as! String == "workout"{
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let workoutView = storyboard.instantiateViewController(withIdentifier: "WorkoutDetailViewController") as! WorkoutDetailViewController
            workoutView.fromDiscover = false
            workoutView.liveAdd = false
            let exerciseData = originalPost["exerciseData"] as! [String:AnyObject]
            WorkoutDetailViewController.exercises = exerciseData["exercises"] as! [[String : AnyObject]]
            workoutView.titleString = exerciseData["title"] as! String
            workoutView.username = originalPost["username"] as! String
            workoutView.playerID = originalPost["posterID"] as! String
            workoutView.workoutID = originalPost["workoutID"] as! String
            workoutView.complete = true
            navigationController?.pushViewController(workoutView, animated: true)
        }else{
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let workoutView = storyboard.instantiateViewController(withIdentifier: "WorkoutDetailViewController") as! WorkoutDetailViewController
            workoutView.fromDiscover = true
            workoutView.liveAdd = false
            let exerciseData = originalPost["exerciseData"] as! [String:AnyObject]
            WorkoutDetailViewController.exercises = exerciseData["exercises"] as! [[String : AnyObject]]
            workoutView.titleString = exerciseData["title"] as! String
            workoutView.username = self.username
            workoutView.playerID = self.userID!
            navigationController?.pushViewController(workoutView, animated: true)
        }
    }
    
    func userTapped(at index: IndexPath) {
        // added in future
        
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        let textAttributes = [NSAttributedString.Key.foregroundColor:Constants.lightColour]
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes
        self.navigationController?.navigationBar.tintColor = Constants.lightColour
    }


}
