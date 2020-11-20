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
import EmptyDataSet_Swift

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
    
    
    // array to hold all players
    var allPlayers : [String] = []
    // array to hold created groups
    var createdGroups : [[String:AnyObject]] = []
    
    // header height
    var headerHeight : CGFloat = 15.0
    
    let backgroundColour = Constants.backgroundColour
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let userID = Auth.auth().currentUser?.uid
        
        DBRef = Database.database().reference().child("users").child(userID!)
        
        
        userRef = Database.database().reference()
        
        tableview.rowHeight = 180
        tableview.backgroundColor = backgroundColour
        

        
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

        if indexPath.section == 0{
            print(allPlayers)
        }else if indexPath.section == createdGroups.count + 1{
            print("do nothing")
        }else{
            print(createdGroups[indexPath.section - 1]["players"] as! [String])
        }
    }
    
    
    func loadPlayers(){
        DBRef.child("players").child("accepted").observeSingleEvent(of: .value) { (snapshot) in
            if let snap = snapshot.value as? [String]{
                self.playersID = snap
                self.loadUsers()
            }
        }
    }
    
    func loadUsers(){
        usernames.removeAll()
        allPlayers.removeAll()
        for player in playersID{
            userRef.child("users").child(player).observe(.value) { (snapshot) in
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
        createdGroups.removeAll()
        DBRef.child("groups").observe(.childAdded, with: { (snapshot) in
            if let snap = snapshot.value as? [String:AnyObject]{
                self.createdGroups.append(snap)
                self.tableview.reloadData()
            }
        }, withCancel: nil)
    }
    
    @objc fileprivate func addNewGroup(_ sender: UIButton){
        print("adding new group...")
        sender.pulsate()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let svc = storyboard.instantiateViewController(identifier: "AddNewGroupViewController") as! AddNewGroupViewController
        svc.allPlayers = self.allPlayers
        svc.noPlayers = self.allPlayers
        navigationController?.pushViewController(svc, animated: true)
    }
    
    func sendToWorkoutPage(sender: UIButton, at index: IndexPath) {
        
        print("section = ", index.section)
        print("tag = ", sender.tag)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let svc = storyboard.instantiateViewController(identifier: "AddWorkoutHomeViewController") as! AddWorkoutHomeViewController
        if index.section == 0{
            svc.groupPlayers = self.allPlayers
        }else{
            svc.groupPlayers = self.createdGroups[index.section - 1]["players"] as! [String]
        }
        AddWorkoutHomeViewController.groupBool = true
        navigationController?.pushViewController(svc, animated: true)
        
    }
    
    
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        loadPlayers()
        loadGroups()
        navigationController?.setNavigationBarHidden(true, animated: true)
        let textAttributes = [NSAttributedString.Key.foregroundColor:#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)]
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    }

    // working on displaying message for the first time
    // function
    override func viewDidAppear(_ animated: Bool) {
         if(!appDelegate.hasLaunchedGroup){
            //set hasAlreadyLaunched to false
            appDelegate.setLaunchedGroup()
            //display user agreement license
            // get width of screen to adjust alert appearance
            let screenSize: CGRect = UIScreen.main.bounds
            let screenWidth = screenSize.width
            
            let appearance = SCLAlertView.SCLAppearance(
                kWindowWidth: screenWidth - 40 )

            let alert = SCLAlertView(appearance: appearance)
            alert.showInfo("GROUPWORKOUT", subTitle: "This page allows you to set workouts for a group of players. We have already made a group containing all your players. You can make more groups containing who you like by tapping the big blue plus button underneath all the groups. You can assign workouts to certain groups by tapping on the group. Enjoy!", closeButtonTitle: "GOT IT!", colorStyle: 0x347aeb, animationStyle: .bottomToTop)
        }
    }

}
