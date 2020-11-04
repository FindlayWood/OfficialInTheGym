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
    
    var DBref:DatabaseReference!
    
    var playerUsernames = [String]()
    var adminsPlayers = [String]()
    var requestedPlayers = [String]()
    var acceptedPlayers = [String]()
    var acceptedUsername = [String]()
    var activities : [[String:AnyObject]] = []
    var users = [Users]()
    var adminsUsers = [Users]()
    
    let userID = Auth.auth().currentUser!.uid
    
    // varibale to check for first time
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var playerfield:UITextField!
    
    @IBAction func addTapped(_ sender:UIButton){
        sender.pulsate()
        let typedNamed = playerfield.text
        if playerUsernames.contains(typedNamed!){
            if self.requestedPlayers.contains(typedNamed!){
                let alert = SCLAlertView()
                alert.showWarning("Already Sent", subTitle: "A request has already been sent to this username. You must wait for them to respond", closeButtonTitle: "ok", animationStyle: .noAnimation)
                playerfield.text = ""
            }
            else if self.acceptedUsername.contains(typedNamed!){
                let alert = SCLAlertView()
                alert.showWarning("Already Added", subTitle: "You have already added this player and they are part of your team.", closeButtonTitle: "ok", animationStyle: .noAnimation)
                playerfield.text = ""
            }
                
            else{
                requestedPlayers.append(typedNamed!)
                for user in users{
                    if user.username == typedNamed{
                        self.adminsUsers.append(user)
                    }
                }
                self.DBref.child("users").child(self.userID).child("players").child("requested").setValue(requestedPlayers)
                let actData = ["time":ServerValue.timestamp(),
                               "type":"Request Sent",
                               "message":"You sent a request to \(typedNamed!)."] as [String:AnyObject]
                //self.activities.insert(actData, at: 0)
                //self.DBref.child("users").child(self.userID).child("activities").setValue(self.activities)
                self.DBref.child("users").child(self.userID).child("activities").childByAutoId().setValue(actData)
                let alert = SCLAlertView()
                alert.showSuccess("Added!", subTitle: "A request has been sent to the player. They will have to accept before you can assign them workouts.", closeButtonTitle: "ok", animationStyle: .noAnimation)
                playerfield.text = ""
            }
            
        }
        else{
            let alert = SCLAlertView()
            alert.showError("Error!", subTitle: "This username doesn't exist. Be sure to check with your players what their usernames are. Be careful when typing, they are case sensitive.", closeButtonTitle: "ok", animationStyle: .noAnimation)
            
            playerfield.text = ""
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        
        DBref = Database.database().reference()
        
        self.DBref.child("users").child(self.userID).child("players").child("requested").observeSingleEvent(of: .value) { (snapshot) in
            if let snap = snapshot.value as? [String]{
                self.requestedPlayers = snap
            }
            
            
        }
        
        self.DBref.child("users").child(self.userID).child("players").child("accepted").observeSingleEvent(of: .value) { (snapshot) in
            if let snap = snapshot.value as? [String]{
                self.acceptedPlayers = snap
                for player in self.acceptedPlayers{
                    self.DBref.child("users").child(player).observe(.value, with: { (snapshot) in
                        if let snap = snapshot.value as? [String:AnyObject]{
                            let uid = snap["username"] as? String
                            self.acceptedUsername.append(uid!)
                        }
                    })
                }
            }
        }
        
        self.DBref.child("users").observe(.childAdded, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject]{
                let user = Users()
                user.username = dictionary["username"] as? String
                user.admin = dictionary["admin"] as? Bool
                user.email = dictionary["email"] as? String
                if user.admin == false{
                    self.playerUsernames.append(user.username!)
                    self.users.append(user)
                }
            }
        }, withCancel: nil)

        
        
    }
    
    // function not needed after update
    /*func loadActivities(){
        activities.removeAll()
        let userID = Auth.auth().currentUser?.uid
        DBref.child("users").child(userID!).child("activities").observe(.childAdded, with: { (snapshot) in
            if let snap = snapshot.value as? [String:AnyObject]{
                self.activities.append(snap)
            }
        }, withCancel: nil)
    }*/
    
    override func viewWillAppear(_ animated: Bool) {
        //loadActivities()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    // working on displaying message for the first time
    // function
    override func viewDidAppear(_ animated: Bool) {
         if(!appDelegate.hasLaunchedAddPlayers){
            //set hasAlreadyLaunched to false
            appDelegate.setLaunchedAddPlayers()
            //display user agreement license
            // get width of screen to adjust alert appearance
            let screenSize: CGRect = UIScreen.main.bounds
            let screenWidth = screenSize.width
            
            let appearance = SCLAlertView.SCLAppearance(
                kWindowWidth: screenWidth - 40 )

            let alert = SCLAlertView(appearance: appearance)
            alert.showInfo("ADDPLAYER", subTitle: "This page will allow you to send requests to players. You just have to type in the player's username (not email) to send them a request. Once they accept, you will then be able to set them workouts. So tell your players to download the app and signup with a player account. Enjoy!", closeButtonTitle: "GOT IT!", colorStyle: 0x347aeb, animationStyle: .bottomToTop)
        }
    }


}
