//
//  MakePostViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 08/12/2020.
//  Copyright © 2020 FindlayWood. All rights reserved.
//

import UIKit
import Firebase
import SCLAlertView

class MakePostViewController: UIViewController {
    
    @IBOutlet weak var text:UITextView!
    
    @IBOutlet weak var postButton:UIButton!
    
    @IBOutlet weak var viewerLabel:UITextView!
    
    @IBOutlet weak var privacyButton:UIButton!
    
    var placeHolder: String = "write something here..."
    
    var DBRef:DatabaseReference!
    
    let userID = Auth.auth().currentUser?.uid
    
    var playersID:[String] = []
    
    var profileImage:UIImage!
    var profileImageURL:String!
    
    var userName = ViewController.username

    // variables to allow posting to groups
    var groupBool:Bool!
    var group:[String] = []
    var groupName:String!
    var groupID:String!
    
    // variables to allow a player to post
    var playerPost:Bool!
    var playerCoaches:[String] = []
    var followers:[String] = [String]()
    
    var isPrivate:Bool = false
    
    let selection = UISelectionFeedbackGenerator()
    let haptic = UINotificationFeedbackGenerator()
    
    // delegate to report back to group
    var delegate : GroupPageProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        text.textContainer.maximumNumberOfLines = 10
        text.textContainer.lineBreakMode = .byTruncatingTail
        
        text.text = placeHolder
        text.textColor = UIColor.lightGray
        text.delegate = self
        text.tintColor = UIColor.white
        postButton.setTitleColor(UIColor.lightGray, for: .normal)
        postButton.isUserInteractionEnabled = false
        
        DBRef = Database.database().reference()
        
        hideKeyboardWhenTappedAround()
        
        if groupBool == true{
            viewerLabel.text = "This post will only be seen by users who are a part of the group \(groupName!). It will not appear on your public profile."
            self.privacyButton.setImage(UIImage(named: "locked_icon"), for: .normal)
            self.privacyButton.isUserInteractionEnabled = false
        }else if playerPost == true{
            self.loadCoaches()
            viewerLabel.text = "This post is public and will be seen by all your coaches, followers and anyone who views your public profile. Tap the icon below to make it private."
        }else{
            viewerLabel.text = "This post is public and will be seen by all of your players, followers and anyone who views your public profile. Tap the icon below to make it private."
        }
        
        LoadFollowers.returnFollowers(for: userID!) { (followers) in
            self.followers = followers
        }

        selection.prepare()
        haptic.prepare()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func postPressed(_ sender:UIButton){
        if text.text == placeHolder || text.text == "" || text.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty{
            print("nope!")
        }else{
            haptic.notificationOccurred(.success)
            if groupBool == true{
                postToGroup()
            }else if playerPost == true{
                postFromPlayer()
            }else{
                let postSelfReferences = Database.database().reference().child("PostSelfReferences").child(self.userID!)
                let postRef = Database.database().reference().child("Posts").childByAutoId()
                let postID = postRef.key!
                
                let timeLineRef = Database.database().reference().child("Timeline")
                
                
                let postData = ["type": "post",
                                "posterID": userID!,
                                "message": text.text!,
                                "username": userName!,
                                "time": ServerValue.timestamp(),
                                "isPrivate" : self.isPrivate,
                                "group": false] as [String : Any]

                postRef.setValue(postData)
                timeLineRef.child(userID!).child(postID).setValue(true)
                postSelfReferences.child(postID).setValue(true)
                for player in playersID{
                    timeLineRef.child(player).child(postID).setValue(true)
                }
                
                for follower in followers{
                    timeLineRef.child(follower).child(postID).setValue(true)
                }
                
                
                text.text = ""
                self.dismiss(animated: true, completion: nil)
            }   
        }
        
        
    }
    
    func postToGroup(){
        let postRef = Database.database().reference().child("GroupPosts").child(groupID).childByAutoId()
        
        let postData = ["type": "post",
                        "posterID": userID!,
                        "message": text.text!,
                        "username": userName!,
                        "time": ServerValue.timestamp(),
                        "isPrivate" : true,
                        "group": true] as [String : Any]

        postRef.setValue(postData) { (error, snapshot) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                self.text.text = ""
                self.delegate.madeAPost()
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func postFromPlayer(){
        let postSelfReferences = Database.database().reference().child("PostSelfReferences").child(self.userID!)
        let postRef = Database.database().reference().child("Posts").childByAutoId()
        let postID = postRef.key!
        
        let timeLineRef = Database.database().reference().child("Timeline")
        
        let postData = ["type": "post",
                        "posterID": userID!,
                        "message": text.text!,
                        "username": userName!,
                        "time": ServerValue.timestamp(),
                        "isPrivate" : self.isPrivate,
                        "group": false] as [String : Any]

        postRef.setValue(postData)
        timeLineRef.child(userID!).child(postID).setValue(true)
        postSelfReferences.child(postID).setValue(true)
        for coach in playerCoaches{
            timeLineRef.child(coach).child(postID).setValue(true)
        }

        for follower in followers{
            timeLineRef.child(follower).child(postID).setValue(true)
        }
        
        
        text.text = ""
        self.dismiss(animated: true, completion: nil)
    }
    
    func loadCoaches(){
        let coachesRef = Database.database().reference().child("PlayerCoaches").child(self.userID!)
        coachesRef.observeSingleEvent(of: .childAdded) { (snapshot) in
            self.playerCoaches.append(snapshot.key)
        }
    }
    
    func loadFollowers(){
        let followRef = Database.database().reference().child("Followers").child(self.userID!)
        followRef.observeSingleEvent(of: .childAdded) { (snapshot) in
            self.followers.append(snapshot.key)
        }
    }
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if text.textColor == UIColor.lightGray {
            text.text = nil
            text.textColor = UIColor.white
            postButton.setTitleColor(UIColor.white, for: .normal)
            postButton.isUserInteractionEnabled = true
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if text.text.isEmpty || text.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            text.text = placeHolder
            text.textColor = UIColor.lightGray
            postButton.setTitleColor(UIColor.lightGray, for: .normal)
            postButton.isUserInteractionEnabled = false
        }
        
        
    }
    @IBAction func changePrivacy(_ sender:UIButton){
        selection.selectionChanged()
        switch self.isPrivate {
        case true:
            self.isPrivate = false
            if playerPost == true{
                viewerLabel.text = "This post is public and will be seen by all your coaches, followers and anyone who views your public profile. Tap the icon below to make it private."
            }else{
                viewerLabel.text = "This post is public and will be seen by all of your players, followers and anyone who views your public profile. Tap the icon below to make it private."
            }
            sender.setImage(UIImage(named: "public_icon"), for: .normal)
        case false:
            self.isPrivate = true
            if playerPost == true{
                viewerLabel.text = "This post is private and will only be seen by your coaches and followers. Tap the icon below to make it public."
            }else{
                viewerLabel.text = "This post is private and will only be seen by your players, followers. Tap the icon below to make it public."
            }
            sender.setImage(UIImage(named: "locked_icon"), for: .normal)
        }
    }

    @IBAction func cancel(_ sender:UIButton){
        self.dismiss(animated: true, completion: nil)
        //self.navigationController?.popViewController(animated: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        //loadProfilePhoto()
    }

}
