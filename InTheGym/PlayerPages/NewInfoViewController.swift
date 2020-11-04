//
//  NewInfoViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 01/10/2020.
//  Copyright © 2020 FindlayWood. All rights reserved.
//

import UIKit
import Firebase

class NewInfoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // variable to hold the user id of the coach
    var adminKey:String = ""
    
    var requesters = [String]()
    var requestKeys = [String]()
    
    // varibale to hold the username.
    // MARK: hard coding the username to test new page. Will need to change
    var username:String = ""
    
    // outlets to view
    @IBOutlet weak var tableview:UITableView!
    @IBOutlet weak var nameLabel:UILabel!
    //@IBOutlet weak var usernameLabel:UILabel!
    //@IBOutlet weak var emailLabel:UILabel!
    //@IBOutlet weak var countedLabel:UILabel!
    
    // array of tableview contents
    var tableContents = ["Coaches", "PBs", "Workout Scores", "Requests", "Settings"]
    var tabQ = ["AccountType", "Username", "Email", "Workouts Complete"]
    var tabA = [String]()
    
    // reference to the database
    var DBRef:DatabaseReference!
    
    // id of the current user
    let userID = Auth.auth().currentUser?.uid
    

    override func viewDidLoad() {
        super.viewDidLoad()
        DBRef = Database.database().reference()
        
        self.tableview.rowHeight = 60
        self.tableview.isScrollEnabled = true
        
        self.tableview.tableFooterView = UIView()
        
        self.username = PlayerActivityViewController.username
        //self.usernameLabel.text = "@\(PlayerActivityViewController.username ?? "@username")"

        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 4
        case 1:
            return 5
        default:
            return 0
        }
    }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = self.tableview.dequeueReusableCell(withIdentifier: "cell") as! NewInfoTableViewCell
            cell.selectionStyle = .none
            
            if indexPath.section == 0{
                
                self.DBRef.child("users").child(userID!).observe(.value) { (snapshot) in
                            if let snap = snapshot.value as? [String:Any]{
                                self.tabA.removeAll()
                                let first = snap["firstName"] as? String ?? "FIRST"
                                let last = snap["lastName"] as? String ?? "LAST"
                                self.tabA.append(self.username)
                                //self.nameLabel.text = "\(first) \(last)"
                                //self.emailLabel.text = snap["email"] as? String
                                let email = snap["email"] as? String
                                self.tabA.append(email!)
                                let counted = snap["numberOfCompletes"] as? Int
                                self.tabA.append("\(counted!)")
                                //self.countedLabel.text = "\(counted ?? 0)"
                                    
                                    
                                switch indexPath.row {
                                            case 0:
                                                cell.pic.image = UIImage(named: "benchpress_icon")
                                                cell.QLabel.text = "AccountType:"
                                                cell.ALabel.text = "Player"
                                            case 1:
                                                cell.pic.image = UIImage(named: "name_icon")
                                                cell.QLabel.text = "Username:"
                                                cell.ALabel.text = self.username
                                            case 2:
                                                cell.pic.image = UIImage(named: "email2_icon")
                                                cell.QLabel.text = "Email:"
                                                cell.ALabel.text = self.tabA[1]
                                            case 3:
                                                cell.pic.image = UIImage(named: "Workout Completed")
                                                cell.QLabel.text = "Workouts Complete:"
                                                cell.ALabel.text = self.tabA[2]
                                                cell.ALabel.textColor = #colorLiteral(red: 0, green: 0.4618991017, blue: 1, alpha: 1)
                                                cell.ALabel.font = UIFont.boldSystemFont(ofSize: 30)
                                            default:
                                                print("ouch")
                                            }
                                }
                            }

            }
            
            if indexPath.section == 1{
                cell.isUserInteractionEnabled = true
                cell.accessoryType = .disclosureIndicator
                switch indexPath.row {
                case 0:
                    cell.pic.image = UIImage(named: "coach_icon")
                    cell.QLabel.text = tableContents[indexPath.row]
                    cell.ALabel.text = ""
                case 1:
                    cell.pic.image = UIImage(named: "clipboard_icon")
                    cell.QLabel.text = tableContents[indexPath.row]
                    cell.ALabel.text = ""
                case 2:
                    cell.pic.image = UIImage(named: "scores_icon")
                    cell.QLabel.text = tableContents[indexPath.row]
                    cell.ALabel.text = ""
                case 3:
                    cell.pic.image = UIImage(named: "trainer_icon")
                    cell.QLabel.text = tableContents[indexPath.row]
                    cell.ALabel.text = ""
                case 4:
                    cell.pic.image = UIImage(named: "settings_icon")
                    cell.QLabel.text = tableContents[indexPath.row]
                    cell.ALabel.text = ""
                default:
                    print("ouch")
                }
            }
            
            
            
            return cell
        }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1{
            switch indexPath.row {
            case 0:
                let Storyboard = UIStoryboard(name: "Main", bundle: nil)
                let SVC = Storyboard.instantiateViewController(withIdentifier: "COACHESViewController") as! COACHESViewController
                self.navigationController?.pushViewController(SVC, animated: true)
            case 1:
                let Storyboard = UIStoryboard(name: "Main", bundle: nil)
                let SVC = Storyboard.instantiateViewController(withIdentifier: "PBsViewController") as! PBsViewController
                SVC.username = self.username
                self.navigationController?.pushViewController(SVC, animated: true)
            case 2:
                let StoryBoard = UIStoryboard(name: "Main", bundle: nil)
                let SVC = StoryBoard.instantiateViewController(withIdentifier: "MYSCORESViewController") as! MYSCORESViewController
                navigationController?.pushViewController(SVC, animated: true)
            case 3:
                let Storyboard = UIStoryboard(name: "Main", bundle: nil)
                let SVC = Storyboard.instantiateViewController(withIdentifier: "RequestsViewController") as! RequestsViewController
                SVC.requesters = self.requesters
                SVC.requestKeys = self.requestKeys
                SVC.username = self.username
                self.navigationController?.pushViewController(SVC, animated: true)
            case 4:
                let StoryBoard = UIStoryboard(name: "Main", bundle: nil)
                let SVC = StoryBoard.instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
                navigationController?.pushViewController(SVC, animated: true)
            default:
                print("ouch")
            }
        }
    }
    
    
    // function to load user info to display at the top of the view
    func loadUserInfo(){
        
        var coachName:String!
        self.DBRef.child("users").child(userID!).observe(.value) { (snapshot) in
            if let snap = snapshot.value as? [String:Any]{
                let first = snap["firstName"] as? String ?? "FIRST"
                let last = snap["lastName"] as? String ?? "LAST"
                self.tabA.append("\(first) \(last)")
                self.nameLabel.text = "\(first) \(last)"
                //self.emailLabel.text = snap["email"] as? String
                let email = snap["email"] as? String
                self.tabA.append(email!)
                let counted = snap["numberOfCompletes"] as? Int
                self.tabA.append("\(counted!)")
                //self.countedLabel.text = "\(counted ?? 0)"
                coachName = snap["coachName"] as? String ?? ""
                //self.coachUsernameLabel.text = "@\(coachName!)"
                //self.tableview.reloadData()
            }
        }
        
        // needs edit. cant use .contain
        
        self.DBRef.child("users").observe(.childAdded, with: { (snapshot) in
            if let snap = snapshot.value as? [String:Any]{
                let x = snap["username"] as! String
                // editing below line from x.contains(coachName) to x == coachName
                // worked fine and fixed error
                if (x == coachName){
                    self.adminKey = snapshot.key
                    self.DBRef.child("users").child(self.adminKey).observe(.value, with: { (snapshot) in
                        if let snap = snapshot.value as? [String:Any]{
                            let first = snap["firstName"] as? String ?? "First"
                            let last = snap["lastName"] as? String ?? "Last"
                            //self.nameLabel.text = "\(first) \(last)"
                            //self.coachNameLabel.text = "\(first) \(last)"
                            let username = snap["username"] as? String
                            //self.coachUsernameLabel.text = "@\(username ?? "")"
                            //self.coachEmailLabel.text = snap["email"] as? String
                            //self.tableview.reloadData()
                        }
                    }, withCancel: nil)
                }
            }
        }, withCancel: nil)
        
    }
    
    func requests(){
        self.requesters.removeAll()
        self.requestKeys.removeAll()
        var requestCount = 0
        self.DBRef.child("users").observe(.childAdded, with: { (snapshot) in
            if let snap = snapshot.value as? [String:Any]{
                if snap["admin"] as! Bool == true{
                    if let playerSnap = snap["players"] as? [String:Any]{
                        if let requests = playerSnap["requested"] as? [String]{
                            if requests.contains(self.username){
                                requestCount = requestCount + 1
                                let coach = snap["username"] as! String
                                self.requesters.append(coach)
                                self.requestKeys.append(snapshot.key)
                                //self.adminLabel.text = "you have \(requestCount) new requests"
                                //self.acceptRequestButton.isHidden = false
                            }
                            else{
                                //self.adminLabel.text = "You don't have any new requests."
                               //self.acceptRequestButton.isHidden = true
                            }
                        }
                        else{
                            //self.adminLabel.text = "You don't have any new requests."
                            //self.acceptRequestButton.isHidden = true
                        }
                    }
                }
            }
        }, withCancel: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        loadUserInfo()
        requests()
        //self.tableview.reloadData()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }

}
