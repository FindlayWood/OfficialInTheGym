//
//  AddNewGroupViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 18/11/2020.
//  Copyright © 2020 FindlayWood. All rights reserved.
//

import UIKit
import Firebase
import SCLAlertView

class AddNewGroupViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, Storyboarded {

    // outlet to tableview
    @IBOutlet weak var tableview:UITableView!
    
    // outlet to textfields
    @IBOutlet weak var titleField:UITextField!
    @IBOutlet weak var subTitleField:UITextField!
    
    // outlet to player counter label
    @IBOutlet weak var playerCount:UILabel!
    var counter : Int = 0
    
    
    // array of all players passed from previous page
    var allPlayers : [String] = []
    var noPlayers : [String] = []
    var playersID : [String] = []
    
    // array of players in the new group
    var newGroup : [String] = []
    var newGroupUsernames : [String] = []
    
    // varibles to create the new view displaying the players
    let subTableview = UITableView()
    let done = UIButton()
    let label = UILabel()
    let shadowView = UIView()
    let display = UIView()
    
    // database reference
    var DBRef : DatabaseReference!
    var actRef : DatabaseReference!
    let userID = Auth.auth().currentUser?.uid
    
    // delegate to report back to mygroups
//    var delegate : MyGroupsProtocol!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleField.delegate = self
        titleField.returnKeyType = .done
        titleField.tintColor = .white
        subTitleField.delegate = self
        subTitleField.returnKeyType = .done
        subTitleField.tintColor = .white
        
        DBRef = Database.database().reference().child("Groups")
        actRef = Database.database().reference().child("Activities")
        
        tableview.layer.cornerRadius = 10
        tableview.layer.borderWidth = 2
        tableview.layer.borderColor = UIColor.black.cgColor
        
        tableview.tableFooterView = UIView()
        subTableview.tableFooterView = UIView()

        loadPlayers()
    }
    
    func loadPlayers(){
        LoadFollowers.returnPlayers(for: userID!) { (players) in
            for player in players{
                self.playersID.append(player.uid)
                self.noPlayers.append(player.username)
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == subTableview {return noPlayers.count} else {return newGroup.count}
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.selectionStyle = .none
        cell.layoutMargins = UIEdgeInsets.zero
        cell.separatorInset = UIEdgeInsets.zero
        
        if tableView == subTableview {
            cell.textLabel?.text = noPlayers[indexPath.row]} else {cell.textLabel?.text = newGroupUsernames[indexPath.row]}
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == subTableview{
            self.newGroup.append(playersID[indexPath.row])
            self.newGroupUsernames.append(noPlayers[indexPath.row])
            self.noPlayers.remove(at: indexPath.row)
            self.playersID.remove(at: indexPath.row)
            counter += 1
            playerCount.text = "Players: \(counter)"
            subTableview.reloadData()
            tableview.reloadData()
        }
    }
    
    @IBAction func createPressed(_ sender:UIButton){
        if titleField.text == ""{
            titleField.layer.borderWidth = 1
            titleField.layer.borderColor = UIColor.red.cgColor
        }
        else if subTitleField.text == "" {
            titleField.layer.borderWidth = 0
            subTitleField.layer.borderWidth = 1
            subTitleField.layer.borderColor = UIColor.red.cgColor

        }else if newGroup.count == 0{
            subTitleField.layer.borderWidth = 0
            tableview.layer.borderColor = UIColor.red.cgColor
        }else{
            tableview.layer.borderColor = UIColor.black.cgColor
            let newGroupData = ["title": self.titleField.text!,
                                "description": self.subTitleField.text!,
                                "leader":self.userID!] as [String : Any]
            
            let groupRef = Database.database().reference().child("Groups").childByAutoId()
            let groupID = groupRef.key!
            let membersRef = Database.database().reference().child("GroupMembers").child(groupID)
            let groupSelfRef = Database.database().reference().child("GroupsReferences")
            let leaderRef = Database.database().reference().child("GroupsLeaderReferences").child(self.userID!).child(groupID)
            
            groupRef.setValue(newGroupData)
            
            membersRef.child(self.userID!).setValue(true)
            groupSelfRef.child(self.userID!).child(groupID).setValue(true)
            leaderRef.setValue(true)
            
            for player in self.newGroup{
                membersRef.child(player).setValue(true)
                groupSelfRef.child(player).child(groupID).setValue(true)
            }
            
            let actData = ["time": ServerValue.timestamp(),
                           "message": "You created a new group, \(self.titleField.text!).",
                           "type": "New Group",
                           "isPrivate" : true] as [String:AnyObject]
            
            actRef.child(self.userID!).childByAutoId().setValue(actData)
            
            let PostRef = Database.database().reference().child("Posts").childByAutoId()
            let postRefKey = PostRef.key!
                                
            
            let timeLineRef = Database.database().reference().child("Timeline").child(self.userID!)
            timeLineRef.child(postRefKey).setValue(true)
            PostRef.setValue(actData)
            
            
            let alert = SCLAlertView()
            alert.showSuccess("New Group", subTitle: "You created a new group, \(titleField.text ?? "group"), you can now set workouts for this group specifically.", closeButtonTitle: "Ok")
            titleField.text = ""
            subTitleField.text = ""
            newGroup.removeAll()
//            self.delegate.addedNewGroup()

            
            navigationController?.popViewController(animated: true)
            
        }
        
    }
    
    func areFieldsFilled() -> Bool{
        if titleField.text == "" {return false} else {return true}
    }
    
    @IBAction func addPlayerToGroup(_ sender:UIButton){
        
        sender.pulsate()
        
        // shadow over view under tableview
        shadowView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.addSubview(shadowView)
        shadowView.frame = view.bounds
        
        // view to hold tableview
        display.backgroundColor = .white
        display.layer.cornerRadius = 10
        display.layer.borderWidth = 2
        display.layer.borderColor = UIColor.black.cgColor
        view.addSubview(display)
        display.frame = view.bounds.insetBy(dx: 20, dy: 100)
        
        // label at the top
        label.text = "PLAYERS"
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        display.addSubview(label)
        label.topAnchor.constraint(equalTo: display.topAnchor, constant: 10).isActive = true
        label.centerXAnchor.constraint(equalTo: display.centerXAnchor).isActive = true
        
        // tableview to hold players
        subTableview.frame = display.bounds.insetBy(dx: 20, dy: 60)
        subTableview.separatorStyle = .singleLine
        subTableview.layer.borderWidth = 2
        subTableview.layer.borderColor = UIColor.black.cgColor
        subTableview.layer.cornerRadius = 10
        subTableview.delegate = self
        subTableview.dataSource = self
        subTableview.translatesAutoresizingMaskIntoConstraints = false
        display.addSubview(subTableview)
    
        
        // button at bottom of display
        done.setTitle("DONE", for: .normal)
        done.titleLabel?.font = UIFont(name: "Menlo-Bold", size: 20)
        done.backgroundColor = Constants.buttonColour
        done.layer.cornerRadius = 15
        done.layer.borderWidth = 2
        done.layer.borderColor = UIColor.black.cgColor
        done.translatesAutoresizingMaskIntoConstraints = false
        display.addSubview(done)
        done.bottomAnchor.constraint(equalTo: display.bottomAnchor, constant: -10).isActive = true
        done.centerXAnchor.constraint(equalTo: display.centerXAnchor).isActive = true
        done.leadingAnchor.constraint(equalTo: display.leadingAnchor, constant: 20).isActive = true
        done.trailingAnchor.constraint(equalTo: display.trailingAnchor, constant: -20).isActive = true
        done.addTarget(self, action: #selector(removeDisplay), for: .touchUpInside)
        done.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
    }
    
    @objc func removeDisplay(){
        shadowView.removeFromSuperview()
        display.removeFromSuperview()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: false)
    }

}
