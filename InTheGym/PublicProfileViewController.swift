//
//  PublicProfileViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 07/01/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit
import Firebase

class PublicProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var profileImage:UIImageView!
    @IBOutlet weak var username:UILabel!
    @IBOutlet weak var fullName:UILabel!
    @IBOutlet weak var followButton:UIButton!
    
    @IBOutlet weak var tableview:UITableView!
    
    var user : Users!
    var posts : [[String:AnyObject]] = []
    
    let userID = Auth.auth().currentUser!.uid
    
    var DBRef:DatabaseReference!

    override func viewDidLoad() {
        super.viewDidLoad()

        
        username.text = user.username
        fullName.text = user.firstName! + " " + user.lastName!
        profileImage.image = UIImage(named: "player_icon")
        
        checkFollowing()
        
        DBRef = Database.database().reference()
        
        loadPosts()
        tableview.rowHeight = UITableView.automaticDimension
        tableview.estimatedRowHeight = 90
        
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
        //let postKey = postRef.Key!
        
        
        
        
        
    }
    
    func checkFollowing(){
        
        let followingRef = Database.database().reference().child("Following").child(self.userID)
        followingRef.observeSingleEvent(of: .childAdded) { (snapshot) in
            if let snap = snapshot.value as? String{
                if snap == (self.user.uid!){
                    print("following")
                    self.followButton.setTitle("Following", for: .normal)
                    self.followButton.backgroundColor = .lightGray
                    self.followButton.isUserInteractionEnabled = false
                }else{
                    print("not following")
                }
            }
        }
        
    }
    
    func loadPosts(){
        
        var initialLoad = true
        let postRef = Database.database().reference().child("Posts").child(user.uid!)
        postRef.observe(.childAdded) { (snapshot) in
            if let snap = snapshot.value as? [String:AnyObject]{
                
                self.posts.insert(snap, at: 0)
                
                
            }
            
            if initialLoad == false{
                self.tableview.reloadData()
            }
            
        }
        postRef.observeSingleEvent(of: .value) { (_) in
            initialLoad = false
            self.tableview.reloadData()
        }
        
        
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let dateStamp = self.posts[indexPath.row]["time"] as? TimeInterval
        let date = NSDate(timeIntervalSince1970: dateStamp!/1000)
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        let final = formatter.string(from: date as Date)
        
        if posts[indexPath.row]["type"] as? String == "post"{
            //tableview.rowHeight = 180
            let cell = self.tableview.dequeueReusableCell(withIdentifier: "cell2") as! ActivityTableViewCell
            
            let posterID = posts[indexPath.row]["posterID"] as? String
     
            self.DBRef.child("users").child(posterID!).child("profilePhotoURL").observeSingleEvent(of: .value) { (snapshot) in
                
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
            cell.username.text = posts[indexPath.row]["username"] as? String
            cell.postText.text = posts[indexPath.row]["message"] as? String
            return cell
        }
        else if posts[indexPath.row]["type"] as? String == "workout"{
            let cell = self.tableview.dequeueReusableCell(withIdentifier: "cell3") as! ActivityTableViewCell
            
            cell.profilePhoto.image = UIImage(named: "benchpress_icon")
            cell.username.text = posts[indexPath.row]["username"] as? String
            cell.postTime.text = final
            cell.workoutExerciseCount.text = posts[indexPath.row]["numberOfExercises"] as? String
            cell.workoutScore.text = posts[indexPath.row]["score"] as? String
            cell.workoutTime.text = posts[indexPath.row]["timeToComplete"] as? String
            cell.workoutTitle.text = posts[indexPath.row]["workoutTitle"] as? String
            
            
            return cell
            
            
        }
        
        
        
        else{
            
            let cell = self.tableview.dequeueReusableCell(withIdentifier: "cell") as! ActivityTableViewCell
            //tableview.rowHeight = 90
            cell.backgroundColor = .white
            let type = self.posts[indexPath.row]["type"] as? String
            cell.type.text = type
            cell.time.text = final
            cell.message.text = self.posts[indexPath.row]["message"] as? String
            cell.pic.image = UIImage(named: type!)
            return cell

        }
        
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        let textAttributes = [NSAttributedString.Key.foregroundColor:Constants.lightColour]
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes
        self.navigationController?.navigationBar.tintColor = Constants.lightColour
    }
    

}
