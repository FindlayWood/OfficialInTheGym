//
//  CoachInfoViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 04/10/2020.
//  Copyright © 2020 FindlayWood. All rights reserved.
//

import UIKit
import Firebase

class CoachInfoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    // variable to hold the user id of the coach
    var adminKey:String = ""
    
    // number of added players
    var playerCount:Int!
    
    // varibale to hold the username.
    // MARK: hard coding the username to test new page. Will need to change
    var username:String = ""
    
    // outlets to view
    @IBOutlet weak var tableview:UITableView!
    @IBOutlet weak var nameLabel:UILabel!
    
    // array of tableview contents
    var tableContents = ["Workout Scores", "Settings"]
    var tabQ = ["AccountType", "Username", "Email", "Players", "Workouts Set"]
    var tabA = [String]()
    
    // reference to the database
    var DBRef:DatabaseReference!
    
    // id of the current user
    let userID = Auth.auth().currentUser?.uid
    
    var players = [String]()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        DBRef = Database.database().reference()
        
        self.tableview.rowHeight = 60
        self.tableview.isScrollEnabled = true
        
        self.tableview.tableFooterView = UIView()
        
        self.username = ViewController.username

        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return tabQ.count
        case 1:
            return tableContents.count
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
                                let first = snap["firstName"] as? String ?? "FIRST"
                                let last = snap["lastName"] as? String ?? "LAST"
                                self.nameLabel.text = "\(first) \(last)"
                                self.tabA.append(self.username)
                                let email = snap["email"] as? String
                                self.tabA.append(email!)
                                let numberOfWorkouts = snap["NumberOfWorkouts"] as? Int
                                self.tabA.append("\(numberOfWorkouts ?? 0)")
                                
                                    
                                    
                                switch indexPath.row {
                                            case 0:
                                                cell.pic.image = UIImage(named: "benchpress_icon")
                                                cell.QLabel.text = "AccountType:"
                                                cell.ALabel.text = "Coach"
                                            case 1:
                                                cell.pic.image = UIImage(named: "name_icon")
                                                cell.QLabel.text = "Username:"
                                                cell.ALabel.text = self.username
                                            case 2:
                                                cell.pic.image = UIImage(named: "email2_icon")
                                                cell.QLabel.text = "Email:"
                                                cell.ALabel.text = self.tabA[1]
                                            case 3:
                                                cell.pic.image = UIImage(named: "numbers_icon")
                                                cell.QLabel.text = "Players:"
                                                cell.ALabel.text = "\(self.playerCount ?? 0)"
                                                cell.ALabel.textColor = #colorLiteral(red: 0, green: 0.4618991017, blue: 1, alpha: 1)
                                                cell.ALabel.font = UIFont.boldSystemFont(ofSize: 30)
                                            case 4:
                                                cell.pic.image = UIImage(named: "Set Workout")
                                                cell.QLabel.text = "Number of Workouts:"
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
                    cell.pic.image = UIImage(named: "scores_icon")
                    cell.QLabel.text = tableContents[indexPath.row]
                    cell.ALabel.text = ""
                case 1:
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
                let SVC = Storyboard.instantiateViewController(withIdentifier: "CoachScoresViewController") as! CoachScoresViewController
                self.navigationController?.pushViewController(SVC, animated: true)
            case 1:
                let StoryBoard = UIStoryboard(name: "Main", bundle: nil)
                let SVC = StoryBoard.instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
                navigationController?.pushViewController(SVC, animated: true)
            default:
                print("ouch")
            }
        }
    }
    
    
    func loadInfo(){
        DBRef.child("users").child(userID!).observe(.value) { (snapshot) in
            if let snap = snapshot.value as? [String:AnyObject]{
                let first = snap["firstName"] as? String ?? "First"
                let last = snap["lastName"] as? String ?? "Last"
                self.nameLabel.text = "\(first) \(last)"
            }
        }
    }
    
    func loadNumberOfUsers(){
        DBRef.child("users").child(userID!).child("players").child("accepted").observe(.childAdded) { (snapshot) in
            if let snap = snapshot.value as? String{
                self.players.append(snap)
            }
        }
        
        DBRef.child("users").child(userID!).child("players").child("accepted").observeSingleEvent(of: .value) { (snapshot) in
            self.playerCount = self.players.count
        }
    }
    
    
    

    override func viewWillAppear(_ animated: Bool) {
        loadInfo()
        loadNumberOfUsers()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        let textAttributes = [NSAttributedString.Key.foregroundColor:Constants.lightColour]
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes
        self.navigationController?.navigationBar.tintColor = Constants.lightColour
    }

}
