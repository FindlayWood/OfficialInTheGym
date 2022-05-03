//
//  GeneralWorkoutViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 21/02/2020.
//  Copyright © 2020 FindlayWood. All rights reserved.
//

import UIKit
import Firebase
import SCLAlertView

//this class is for trying to let the coach create a workout that can be given to several players

@available(iOS 13.0, *)
class GeneralWorkoutViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, addWorkout {
    
    
    //outlets for the 2 tableviews
    @IBOutlet weak var tableview:UITableView!
    
    
    //array for usernames and player id
    var usernames = [String]()
    var playersID = [String]()
    
    //database references
    var DBRef:DatabaseReference!
    var userRef:DatabaseReference!
    
    // varibale to check for first time
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    // array for all players as users
    var players = [Users]()
    
    // array to hold all players
    var allPlayers : [String] = []
    // array to hold created groups
    var createdGroups : [[String:AnyObject]] = []
    
    // header height
    var headerHeight : CGFloat = 15.0
    
    let backgroundColour = Constants.lightColour
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let userID = Auth.auth().currentUser?.uid
        
        DBRef = Database.database().reference().child("users").child(userID!)
        
        
        userRef = Database.database().reference()
        
        tableview.rowHeight = 180
        tableview.backgroundColor = backgroundColour
        
        loadGroups()
        loadPlayers()

        
    }
    
    //loading tableview
    //number of rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return createdGroups.count + 2
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return headerHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let background = UILabel()
        background.backgroundColor = backgroundColour
        return background
    }
    
    //displaying each row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableview.dequeueReusableCell(withIdentifier: "cell") as! GeneralTableViewCell
        cell.layer.cornerRadius = 10
        cell.layer.borderWidth = 2.0
        cell.layer.borderColor = UIColor.black.cgColor
        cell.selectionStyle = .none
        
        
        if indexPath.section == 0 {
            cell.title.text = "ALL PLAYERS"
            cell.subTitle.text = "This group contains all the players you have added."
            cell.playerCount.text = "Players: \(allPlayers.count.description)"
            cell.delegate = self
            cell.indexPath = indexPath
        }else if indexPath.section == createdGroups.count + 1{
            
            let cell = tableview.dequeueReusableCell(withIdentifier: "cell2") as! GeneralTableViewCell
            cell.backgroundColor = .clear
            cell.selectionStyle = .none
            cell.addButton.addTarget(self, action: #selector(addNewGroup), for: .touchUpInside)
            return cell
        }else{
            cell.title.text = createdGroups[indexPath.section - 1]["title"] as? String
            cell.subTitle.text = createdGroups[indexPath.section - 1]["subTitle"] as? String
            cell.playerCount.text = "Players: \(createdGroups[indexPath.section - 1]["players"]?.count?.description ?? "na")"
            cell.delegate = self
            cell.indexPath = indexPath
        }
        
        
        return cell
        
    }
    
    //selecting each row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let membersPage = storyboard.instantiateViewController(withIdentifier: "GroupMembersViewController") as! GroupMembersViewController
        

        if indexPath.section == 0{
            print(allPlayers)
//            membersPage.groupMembers = self.playersID
        }else if indexPath.section == createdGroups.count + 1{
            print("do nothing")
        }else{
//            membersPage.groupMembers = createdGroups[indexPath.section - 1]["players"] as! [String]
            print(createdGroups[indexPath.section - 1]["players"] as! [String])
        }
        
        self.navigationController?.pushViewController(membersPage, animated: true)
    }
    
    
    func loadPlayers(){
        //self.playersID.removeAll()
        let userID = Auth.auth().currentUser!.uid
        let myGroup = DispatchGroup()
        var tempPlayers = [Users]()
        let playerRef = Database.database().reference().child("CoachPlayers").child(userID)
        playerRef.observe(.value) { (snapshot) in
            if snapshot.exists(){
                for child in snapshot.children{
                    myGroup.enter()
                    UserIDToUser.transform(userID: (child as AnyObject).key) { (user) in
                        tempPlayers.append(user)
                        self.playersID.append(user.uid)
                        self.usernames.append(user.username)
                        self.allPlayers.append(user.username)
                        myGroup.leave()
                    }
                    myGroup.notify(queue: .main){
                        self.players = tempPlayers
                        self.tableview.reloadData()
                    }
                }
            }
        }
    }
    
    func loadUsers(){
        usernames.removeAll()
        allPlayers.removeAll()
        for player in playersID{
            userRef.child("users").child(player).observeSingleEvent(of: .value) { (snapshot) in
                if let snap = snapshot.value as? [String:AnyObject]{
                    let username = snap["username"] as! String
                    self.usernames.append(username)
                    self.allPlayers.append(username)
                    self.tableview.reloadData()
                }
            }
        }
    }
    
    func loadGroups(){
        //createdGroups.removeAll()
        var initialLoad = true
        DBRef.child("groups").observe(.childAdded, with: { (snapshot) in
            if let snap = snapshot.value as? [String:AnyObject]{
                self.createdGroups.append(snap)
            }
            
            if initialLoad == false{
                self.tableview.reloadData()
            }
        }, withCancel: nil)
        
        
        DBRef.child("groups").observeSingleEvent(of: .value) { (_) in
            self.tableview.reloadData()
            initialLoad = false
        }
    }
    
    @objc fileprivate func addNewGroup(_ sender: UIButton){
        print("adding new group...")
        sender.pulsate()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let svc = storyboard.instantiateViewController(identifier: "AddNewGroupViewController") as! AddNewGroupViewController
        svc.allPlayers = self.allPlayers
        svc.noPlayers = self.allPlayers
        svc.playersID = self.playersID
        navigationController?.pushViewController(svc, animated: true)
    }
    
    func sendToWorkoutPage(sender: UIButton, at index: IndexPath) {
        
        print("section = ", index.section)
        print("tag = ", sender.tag)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let svc = storyboard.instantiateViewController(identifier: "AddWorkoutHomeViewController") as! AddWorkoutHomeViewController
        if index.section == 0{
            svc.groupPlayers = self.playersID
        }else{
            svc.groupPlayers = self.createdGroups[index.section - 1]["players"] as! [String]
        }
        AddWorkoutHomeViewController.groupBool = true
        navigationController?.pushViewController(svc, animated: true)
        
    }
    
    func postToGroup(at index: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let postVC = storyboard.instantiateViewController(withIdentifier: "MakePostViewController") as! MakePostViewController
        if index.section == 0{
            postVC.group = self.playersID
            postVC.groupName = "All Players"
        }else{
            postVC.group = self.createdGroups[index.section - 1]["players"] as! [String]
            postVC.groupName = self.createdGroups[index.section - 1]["title"] as? String
        }
        postVC.groupBool = true
        postVC.modalPresentationStyle = .fullScreen
        postVC.modalTransitionStyle = .coverVertical
        self.navigationController?.present(postVC, animated: true, completion: nil)
    }
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        //loadPlayers()
        //loadGroups()
        navigationController?.setNavigationBarHidden(true, animated: true)
        let textAttributes = [NSAttributedString.Key.foregroundColor:#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)]
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    }

}
