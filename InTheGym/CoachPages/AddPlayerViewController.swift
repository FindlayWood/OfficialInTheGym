//
//  AddPlayerViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 30/06/2019.
//  Copyright © 2019 FindlayWood. All rights reserved.
//

import UIKit
import Firebase
import SCLAlertView

class AddPlayerViewController: UIViewController {
    
    //activity indicator when loading
    @IBOutlet weak var activityIndicator:UIActivityIndicatorView!
    
    var DBref:DatabaseReference!
    
    var playerUsernames = [String]()
    var adminsPlayers = [String]()
    var requestedPlayers = [String]()
    var acceptedPlayers = [String]()
    var acceptedUsername = [String]()
    var users = [Users]()
    var adminsUsers = [Users]()
    
    let userID = Auth.auth().currentUser!.uid
    
    // varibale to check for first time
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    let haptic = UINotificationFeedbackGenerator()
    
    @IBOutlet weak var playerfield:UITextField!
    
    @IBAction func addTapped(_ sender:UIButton){
        sender.pulsate()
        let typedNamed = playerfield.text
        activityIndicator.startAnimating()
        var userFound = false
        for user in users{
            if typedNamed == user.username{
                checkForPlayer(on: user) { (player) in
                    if player == false{
                        self.alertPlayer()
                        self.activityIndicator.stopAnimating()
                    }else{
                        self.checkForRequest(on: user) { (requested) in
                            if requested == false{
                                self.alertRequestSent()
                                self.activityIndicator.stopAnimating()
                            }else{
                                self.sendRequestToUser(user: user)
                            }
                        }
                    }
                }
                userFound = true
                break
            }
        }
        if userFound == false{
            activityIndicator.stopAnimating()
            alertNoUserFound()
        }
    }
    
    @IBAction func backPressed(_ sender:UIButton){
        self.dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        playerfield.delegate = self
        haptic.prepare()
        loadUsers()
        activityIndicator.hidesWhenStopped = true
    }
    
    
    // load all players to be able to add by username
    func loadUsers(){
        activityIndicator.startAnimating()
        var initialLoad = true
        let userReference = Database.database().reference().child("users")
        userReference.observe(.childAdded, with: { (snapshot) in
            
            if snapshot.key == self.userID{
                return
            }else{
                if let snap = snapshot.value as? [String:AnyObject]{
                    if snap["admin"] as? Bool == false{
                        let newUser = Users()
                        newUser.username = snap["username"] as? String
                        newUser.firstName = snap["firstName"] as? String ?? "no"
                        newUser.lastName = snap["lastName"] as? String ?? "name"
                        newUser.admin = snap["admin"] as? Bool ?? false
                        newUser.uid = snapshot.key
                        newUser.profilePhotoURL = snap["profilePhotoURL"] as? String
                        newUser.profileBio = snap["profileBio"] as? String
                        self.users.append(newUser)
                    }
                }
            }
            if initialLoad == false{
            }
            
            
        }, withCancel: nil)
        
        userReference.observeSingleEvent(of: .value) { (_) in
            initialLoad = false
            self.activityIndicator.stopAnimating()
        }
    }
    
    func checkForPlayer(on user: Users, completion: @escaping (Bool) -> Void){
        let playerRef = Database.database().reference().child("CoachPlayers").child(self.userID).child(user.uid!)
        playerRef.observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists(){
                completion(false)
            }else{
                completion(true)
            }
        }
    }
    
    
    
    func checkForRequest(on user:Users, completion: @escaping (Bool) -> Void){
        let requestsRef = Database.database().reference().child("CoachRequests").child(self.userID).child(user.uid!)
        requestsRef.observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists(){
                completion(false)
            }else{
                completion(true)
            }
        }
    }
    
    
    func sendRequestToUser(user:Users){
        // requests
        let playerRequestRef = Database.database().reference().child("PlayerRequests").child(user.uid!).child(self.userID)
        let requestSentRef = Database.database().reference().child("CoachRequests").child(self.userID).child(user.uid!)
        requestSentRef.setValue(true)
        playerRequestRef.setValue(true)

        FirebaseAPI.shared().uploadActivity(with: .RequestSent(user.username!))
        let notification = NotificationNewRequest(from: self.userID, to: user.uid!)
        let uploadNotification = NotificationManager(delegate: notification)
        uploadNotification.upload()
        // posts
//        let actData = ["time":ServerValue.timestamp(),
//                       "type":"Request Sent",
//                       "message":"You sent a request to \(user.username!).",
//                       "isPrivate":true,
//                       "posterID":self.userID] as [String:AnyObject]
//        let postRef = Database.database().reference().child("Posts").childByAutoId()
//        let postRefKey = postRef.key
//        postRef.setValue(actData)
//        let posselfreferences = Database.database().reference().child("PostSelfReferences").child(self.userID).child(postRefKey!)
//        posselfreferences.setValue(true)
//        let timelineref = Database.database().reference().child("Timeline").child(self.userID).child(postRefKey!)
//        timelineref.setValue(true)
        
        // userx
        activityIndicator.stopAnimating()
        haptic.notificationOccurred(.success)

        // show alert
        let alert = SCLAlertView()
        alert.showSuccess("Added!", subTitle: "A request has been sent to \(user.username!). They will have to accept before you can assign them workouts, add them to groups and view their workout data.", closeButtonTitle: "ok", animationStyle: .bottomToTop)
        playerfield.text = ""
        
    }
    
    func alertNoUserFound(){
        haptic.notificationOccurred(.error)
        let alert = SCLAlertView()
        alert.showError("Error!", subTitle: "This username doesn't exist. Be sure to check with your players what their usernames are. Be careful when typing, they are case sensitive.", closeButtonTitle: "ok", animationStyle: .topToBottom)
        
        playerfield.text = ""
    }
    
    func alertRequestSent(){
        haptic.notificationOccurred(.warning)
        let alert = SCLAlertView()
        alert.showWarning("Already Sent!", subTitle: "You have already sent a request to this player. You will have to wait until they accept it before you can assign them workouts, add them to groups and monitor their workout data.", closeButtonTitle: "ok", animationStyle: .topToBottom)
        
        playerfield.text = ""
    }
    
    func alertPlayer(){
        haptic.notificationOccurred(.warning)
        let alert = SCLAlertView()
        alert.showError("Already Accepted!", subTitle: "This player has already accepted a request from you. You will find them on the PLAYERS tab. You can assign them workouts, add them to groups and monitor their workout data from there.", closeButtonTitle: "ok", animationStyle: .topToBottom)
        
        playerfield.text = ""
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //loadActivities()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }



}
