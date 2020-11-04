//
//  AdminPlayersViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 29/07/2019.
//  Copyright © 2019 FindlayWood. All rights reserved.
//

import UIKit
import Firebase
import SCLAlertView

class AdminPlayersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableview:UITableView!
    
    var DBref:DatabaseReference!
    var userRef:DatabaseReference!
    
    static var players = [String]()
    var users = [Users]()
    
    // varibale to check for first time
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let userID = Auth.auth().currentUser?.uid
        
        DBref = Database.database().reference().child("users").child(userID!)
        
        
        userRef = Database.database().reference()
        
        self.tableview.rowHeight = 75
        tableview.backgroundColor = .white
    }
    
    
    func loadPlayers(){
        DBref.child("players").child("accepted").observeSingleEvent(of: .value) { (snapshot) in
            if let snap = snapshot.value as? [String]{
                AdminPlayersViewController.self.players = snap
                self.tableview.reloadData()
                self.loadUsers()
            }
        }
    }
    
    func loadUsers(){
        for player in AdminPlayersViewController.players{
            userRef.child("users").child(player).observe(.value) { (snapshot) in
                if let snap = snapshot.value as? [String:AnyObject]{
                    let user = Users()
                    user.username = snap["username"] as? String
                    user.email = snap["email"] as? String
                    user.firstName = snap["firstName"] as? String
                    user.lastName = snap["lastName"] as? String
                    self.users.append(user)
                    
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AdminPlayersViewController.players.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableview.dequeueReusableCell(withIdentifier: "cell") as! PlayerTableViewCell
        cell.backgroundColor = .white
        let currentID = AdminPlayersViewController.players[indexPath.row]
        userRef.child("users").child(currentID).observe(.value) { (snapshot) in
            if let snap = snapshot.value as? [String:AnyObject]{
                let first = snap["firstName"] as! String
                let last = snap["lastName"] as! String
                cell.name.text = "\(first) \(last)"
                let username = snap["username"] as! String
                cell.username.text = "\(username)"
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let StoryBoard = UIStoryboard(name: "Main", bundle: nil)
        let SVC = StoryBoard.instantiateViewController(withIdentifier: "PlayerViewController") as! PlayerViewController
        
        let currentUser = users[indexPath.row]
        SVC.firstNameString = currentUser.firstName!
        SVC.lastNameString = currentUser.lastName!
        SVC.userNameString = currentUser.username!
        SVC.userEmailString = currentUser.email!
        
        self.navigationController?.pushViewController(SVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            AdminPlayersViewController.players.remove(at: indexPath.row)
            users.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .left)
            DBref.child("players").setValue(AdminPlayersViewController.players)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //loadUsers()
        loadPlayers()
        tableview.reloadData()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    // working on displaying message for the first time
    // function
    override func viewDidAppear(_ animated: Bool) {
         if(!appDelegate.hasLaunchedPlayers){
            //set hasAlreadyLaunched to false
            appDelegate.setLaunchedPlayers()
            //display user agreement license
            // get width of screen to adjust alert appearance
            let screenSize: CGRect = UIScreen.main.bounds
            let screenWidth = screenSize.width
            
            let appearance = SCLAlertView.SCLAppearance(
                kWindowWidth: screenWidth - 40 )

            let alert = SCLAlertView(appearance: appearance)
            alert.showInfo("PLAYERS", subTitle: "This page will display all of your players. Players will need to accept your request before they appear on this page. You can send requests on the ADDPLAYER page. You can tap on a player to get more info about them as well as being able to set a workout for them, view all their previous workouts and view their PBs. You can delete a player from your team by swiping left on their name. Enjoy!", closeButtonTitle: "GOT IT!", colorStyle: 0x347aeb, animationStyle: .bottomToTop)
        }
    }

}
