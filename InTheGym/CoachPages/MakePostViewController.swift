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

class MakePostViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var text:UITextView!
    
    @IBOutlet weak var postButton:UIButton!
    
    var placeHolder: String = "write something here..."
    
    var DBRef:DatabaseReference!
    
    let userID = Auth.auth().currentUser?.uid
    
    var playersID:[String] = []
    
    var profileImage:UIImage!
    var profileImageURL:String!
    
    let coachUsername : String = AdminActivityViewController.username

    override func viewDidLoad() {
        super.viewDidLoad()
        
        text.textContainer.maximumNumberOfLines = 5
        text.textContainer.lineBreakMode = .byTruncatingTail
        
        text.text = placeHolder
        text.textColor = UIColor.lightGray
        text.delegate = self
        text.tintColor = UIColor.white
        postButton.setTitleColor(UIColor.lightGray, for: .normal)
        postButton.isUserInteractionEnabled = false
        
        DBRef = Database.database().reference()
        
        hideKeyboardWhenTappedAround()
        
        loadPosts()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func postPressed(_ sender:UIButton){
        if text.text == placeHolder || text.text == "" || text.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty{
            print("nope!")
        }else{
            
            let postRef = Database.database().reference().child("Posts").child(userID!).childByAutoId()
            print(postRef.key!)
            let postID = postRef.key!
            let post = ["message":"ahahaha",
            "posterID": userID!] as [String:Any]
            postRef.setValue(post)
            
            let timeLineRef = Database.database().reference().child("Timeline").child(userID!).childByAutoId()
            let newpost = ["postID": postID,
                           "posterID": userID!]
            timeLineRef.setValue(newpost)
            
//            let postData = ["type": "post",
//                            "posterID": userID!,
//                            "message": text.text!,
//                            "username": coachUsername,
//                            "time": ServerValue.timestamp()] as [String : Any]
//
//            DBRef.child("Activities").child(userID!).childByAutoId().setValue(postData)
//
//            for player in playersID{
//                DBRef.child("Activities").child(player).childByAutoId().setValue(postData)
//            }
            
            text.text = ""
            navigationController?.popViewController(animated: true)
            
            
        }
        
        
    }
    
    
    func loadProfilePhoto(){
        
        DBRef.child("profilePhotoURL").observeSingleEvent(of: .value) { (snapshot) in
            guard let imageURL = snapshot.value else{
                print("no profile pic")
                self.profileImage = UIImage(named: "coach_icon")
                return
            }
            
            let storageRef = Storage.storage().reference()
            let storageProfileRef = storageRef.child("ProfilePhotos").child(self.userID!)
            storageProfileRef.downloadURL { (url, error) in
                if error != nil{
                    print(error?.localizedDescription as Any)
                    return
                }
                print(url?.absoluteString)
                self.profileImageURL = url?.absoluteString
                let data = NSData(contentsOf: url!)
                let image = UIImage(data: data! as Data)
                self.profileImage = image
                
            }
        }
    }
    
    func loadPosts(){
        
        let postsRef = Database.database().reference().child("Posts")
        let timeLineRef = Database.database().reference().child("Timeline").child(userID!)
        timeLineRef.observe(.childAdded) { (snapshot) in
            if let snap = snapshot.value as? [String:AnyObject]{
                let postId = snap["postID"] as! String
                let posterID = snap["posterID"] as! String
                postsRef.child(posterID).child(postId).observeSingleEvent(of: .value) { (snapshot) in
                    if let snap = snapshot.value as? [String:AnyObject]{
                        let postMessage = snap["message"] as! String
                        print(postMessage)
                    }
                    
                }
                
            }
            
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

    @IBAction func cancel(_ sender:UIButton){
        self.navigationController?.popViewController(animated: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        loadProfilePhoto()
    }

}
