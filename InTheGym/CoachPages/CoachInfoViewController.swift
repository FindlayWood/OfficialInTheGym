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
    
    // number of added players
    var playerCount:Int!
    
    // outlets to view
    @IBOutlet weak var tableview:UITableView!
    
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
        
        self.navigationItem.title = "MORE"

        
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
                
                
                
                self.DBRef.child("users").child(userID!).observeSingleEvent(of: .value) { (snapshot) in
                            if let snap = snapshot.value as? [String:Any]{
                                self.tabA.append(ViewController.username)
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
                                                cell.ALabel.text = ViewController.username
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
                    break
                }
            }
            return cell
        }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            return 20
        } else {
            return 0
        }
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
                break
            }
        }
    }
    
    
    func loadNumberOfUsers(){
        let playerCountRef = Database.database().reference().child("CoachPlayers").child(userID!)
        playerCountRef.observeSingleEvent(of: .value) { (snapshot) in
            let playerCount = snapshot.childrenCount
            self.playerCount = Int(playerCount)
            self.tableview.reloadData()
        }
    }
    
    
    

    override func viewWillAppear(_ animated: Bool) {
        loadNumberOfUsers()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        let textAttributes = [NSAttributedString.Key.foregroundColor:Constants.lightColour]
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes
        self.navigationController?.navigationBar.tintColor = Constants.lightColour
    }

}
