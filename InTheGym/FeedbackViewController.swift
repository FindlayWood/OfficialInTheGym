//
//  FeedbackViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 30/04/2020.
//  Copyright © 2020 FindlayWood. All rights reserved.
//

import UIKit
import Firebase
//import SCLAlertView

class FeedbackViewController: UIViewController, UITextViewDelegate {
    
    //outlet to text field for sending feedback
    @IBOutlet var feedback:UITextView!
    
    //databse reference
    var DBRef:DatabaseReference!
    
    //placeholder string variable
    var plcholder:String = "Feedback... \nNew Exercises...\nFound any Bugs...\nNew features..."

    override func viewDidLoad() {
        super.viewDidLoad()
        
        DBRef = Database.database().reference().child("Feedback")
        
        feedback.text = plcholder
        feedback.textColor = UIColor.lightGray
        feedback.delegate = self
        feedback.backgroundColor = .white
        feedback.layer.cornerRadius = 4
        
        self.navigationItem.title = "Feedback"
        
        hideKeyboardWhenTappedAround()

    }
    
    @IBAction func uploadFeedback(_ sender:UIButton){
        if feedback.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty{
            
            // new alert
//            let alert = SCLAlertView()
//            alert.showWarning("Blank Upload", subTitle: "Please write something before uploading feedback. You can write whatever you like. New exercises, new features, found any bugs? Lets us know!", closeButtonTitle: "Ok")
            
        }
        else if feedback.text == plcholder{
            
            // new alert
//            let alert = SCLAlertView()
//            alert.showWarning("Blank Upload", subTitle: "Please write something before uploading feedback. You can write whatever you like. New exercises, new features, found any bugs? Lets us know!", closeButtonTitle: "Ok")
            
        }
        else{
            let text = feedback.text.trimTrailingWhiteSpaces()
            let feedbackData = ["feedback":text,
                            "email":Auth.auth().currentUser?.email] as [String:AnyObject]

            DBRef.childByAutoId().setValue(feedbackData) { (error, snapshot) in
                if let error = error {
                    print(error.localizedDescription)
                    self.showError()
                } else {
                    self.showSuccess()
                }
            }

 
        }
    }
    
    func showSuccess(){
        // new alert
//        let alert = SCLAlertView()
//        alert.showSuccess("Feedback Uploaded!", subTitle: "Thank you for your feedback. We read all of it and are always looking to improve user experience so every bit of feedback is much appreciated.", closeButtonTitle: "Ok")

        feedback.text = plcholder
        feedback.textColor = UIColor.lightGray
    }
    
    func showError(){
//        let alert = SCLAlertView()
//        alert.showError("Woops", subTitle: "Sorry there was an error trying to upload your feedback. Please try again.", closeButtonTitle: "Ok")
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if feedback.textColor == UIColor.lightGray {
            feedback.text = nil
            feedback.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if feedback.text.isEmpty {
            feedback.text = plcholder
            feedback.textColor = UIColor.lightGray
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
        let textAttributes = [NSAttributedString.Key.foregroundColor:#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)]
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    }
    



}
