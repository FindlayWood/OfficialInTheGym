//
//  ReplyViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 23/01/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit
import Firebase

class ReplyViewController: UIViewController, Storyboarded, UITextViewDelegate {
    
    @IBOutlet weak var message:UITextView!
    @IBOutlet weak var replyButton:UIButton!
    
    
    var postID:String!
    var posterID:String!
    var placeholder: String = "write your reply here..."
    let userID = Auth.auth().currentUser!.uid
    var username:String!
    
    // check if replying to group post
    var isGroupPost : Bool!
    var groupID : String!
    
    // protocol to connect back when
    var delegate : DiscussionProtocol!

    override func viewDidLoad() {
        super.viewDidLoad()

        message.text = placeholder
        message.textColor = UIColor.lightGray
        message.delegate = self
        message.tintColor = .white
        replyButton.setTitleColor(.lightGray, for: .normal)
        replyButton.isUserInteractionEnabled = false
        replyButton.contentEdgeInsets = UIEdgeInsets(top: 5, left: 8, bottom: 5, right: 8)
        
        hideKeyboardWhenTappedAround()
        
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if message.textColor == UIColor.lightGray {
            message.text = nil
            message.textColor = UIColor.white
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            replyButton.setTitleColor(UIColor.lightGray, for: .normal)
            replyButton.isUserInteractionEnabled = false
        } else {
            replyButton.setTitleColor(UIColor.white, for: .normal)
            replyButton.isUserInteractionEnabled = true
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if message.text.isEmpty || message.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            message.text = placeholder
            message.textColor = UIColor.lightGray
            replyButton.setTitleColor(UIColor.lightGray, for: .normal)
            replyButton.isUserInteractionEnabled = false
        }
        
        
    }
    
    @IBAction func postPressed(_ sender:UIButton){
        if message.text == placeholder || message.text == "" || message.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty{
            print("nope!")
        }else{
            let replyRef = Database.database().reference().child("PostReplies").child(postID)
            let replyData = ["message": message.text!.trimTrailingWhiteSpaces(),
                             "posterID": self.userID,
                             "time": ServerValue.timestamp(),
                             "username": ViewController.username!] as [String : Any]
            replyRef.childByAutoId().setValue(replyData)
            if isGroupPost == true{
                self.updateGroupPost()
            } else {
                let replyCountRef = Database.database().reference().child("Posts").child(postID)
                
                replyCountRef.runTransactionBlock { (currentData) -> TransactionResult in
                    if var post = currentData.value as? [String:AnyObject]{
                        var replies = post["replyCount"] as? Int ?? 0
                        replies += 1
                        post["replyCount"] = replies as AnyObject
                        currentData.value = post
                        return TransactionResult.success(withValue: currentData)
                    }
                    return TransactionResult.success(withValue: currentData)
                } andCompletionBlock: { (error, committed, snapshot) in
                    if let error = error{
                        print(error.localizedDescription)
                    } else {
                        self.delegate.replyPosted()
                    }
                }
                if self.userID != posterID{
                    let notification = NotificationReplied(from: self.userID, to: posterID, postID: postID)
                    let uploadNotification = NotificationManager(delegate: notification)
                    uploadNotification.upload { _ in
                        
                    }
                    
                }
            }

            self.dismiss(animated: true, completion: nil)

        }
    }
    
    func updateGroupPost(){
        let replyCountRef = Database.database().reference().child("GroupPosts").child(groupID).child(postID)
        
        replyCountRef.runTransactionBlock { (currentData) -> TransactionResult in
            if var post = currentData.value as? [String:AnyObject]{
                var replies = post["replyCount"] as? Int ?? 0
                replies += 1
                post["replyCount"] = replies as AnyObject
                currentData.value = post
                return TransactionResult.success(withValue: currentData)
            }
            return TransactionResult.success(withValue: currentData)
        } andCompletionBlock: { (error, committed, snapshot) in
            if let error = error{
                print(error.localizedDescription)
            } else {
                self.delegate.replyPosted()
            }
        }
        if self.userID != posterID{
            let notification = NotificationGroupReplied(from: self.userID, to: posterID, postID: postID, groupID: groupID)
            let uploadNotification = NotificationManager(delegate: notification)
            uploadNotification.upload { _ in
                
            }
        }
    }
    
    @IBAction func cancel(_ sender:UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }

}
