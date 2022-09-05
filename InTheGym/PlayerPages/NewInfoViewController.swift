//
//  NewInfoViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 01/10/2020.
//  Copyright © 2020 FindlayWood. All rights reserved.
//

import UIKit
import Firebase

class NewInfoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, Storyboarded {
    
    // outlets to view
    @IBOutlet weak var tableview:UITableView!
    
    // array of tableview contents
    var tableContents = ["Coaches", "PBs", "Workload", "Requests", "Settings", "Measure Jump", "Breath Work"]
    var tabQ = ["AccountType", "Username", "Email", "Workouts Complete"]
    var tabA = [String]()
    
    // reference to the database
    var DBRef:DatabaseReference!
    var handle:DatabaseHandle!
    
    // id of the current user
    let userID = Auth.auth().currentUser?.uid
    

    override func viewDidLoad() {
        super.viewDidLoad()
        DBRef = Database.database().reference()
        
        self.tableview.rowHeight = 60
        self.tableview.isScrollEnabled = true
        
        self.tableview.tableFooterView = UIView()
        self.navigationItem.title = "More"
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 4
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
                                self.tabA.removeAll()
                                self.tabA.append(ViewController.username)
                                let email = snap["email"] as? String
                                self.tabA.append(email!)
                                let counted = snap["numberOfCompletes"] as? Int
                                self.tabA.append("\(counted ?? 0)")
                                    
                                    
                                switch indexPath.row {
                                            case 0:
                                                cell.pic.image = UIImage(named: "benchpress_icon")
                                                cell.QLabel.text = "AccountType:"
                                                cell.ALabel.text = "Player"
                                            case 1:
                                                cell.pic.image = UIImage(named: "name_icon")
                                                cell.QLabel.text = "Username:"
                                                cell.ALabel.text = ViewController.username
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
                    cell.pic.image = UIImage(named: "linechart_icon")
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
                case 5:
                    cell.pic.image = UIImage(named: "jump_icon")
                    cell.QLabel.text = tableContents[indexPath.row]
                    cell.ALabel.text = ""
                case 6:
                    cell.pic.image = UIImage(named: "breath_icon")
                    cell.QLabel.text = tableContents[indexPath.row]
                    cell.ALabel.text = ""
                default:
                    print("ouch")
                }
            }
            
            
            
            return cell
        }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 15
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemGray5
        } else {
            view.backgroundColor = .lightGray
        }
        return view
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1{
            switch indexPath.row {
            case 0:
                let Storyboard = UIStoryboard(name: "Main", bundle: nil)
                let SVC = Storyboard.instantiateViewController(withIdentifier: "COACHESViewController") as! COACHESViewController
                self.navigationController?.pushViewController(SVC, animated: true)
            case 1:
                let vc = DisplayExerciseStatsViewController()
                self.navigationController?.pushViewController(vc, animated: true)
//                let Storyboard = UIStoryboard(name: "Main", bundle: nil)
//                let SVC = Storyboard.instantiateViewController(withIdentifier: "PBsViewController") as! PBsViewController
//                SVC.username = ViewController.username
//                self.navigationController?.pushViewController(SVC, animated: true)
            case 2:
                print("wrong option")
//                let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                let SVC = storyboard.instantiateViewController(withIdentifier: "WorkloadDisplayViewController") as! WorkloadDisplayViewController
//                SVC.username = ViewController.username
//                SVC.playerID = Auth.auth().currentUser?.uid
//                SVC.hidesBottomBarWhenPushed = true
//                navigationController?.pushViewController(SVC, animated: true)
            case 3:
//                let Storyboard = UIStoryboard(name: "Main", bundle: nil)
//                let SVC = Storyboard.instantiateViewController(withIdentifier: "RequestsViewController") as! RequestsViewController
                let SVC = RequestsViewController()
                self.navigationController?.pushViewController(SVC, animated: true)
            case 4:
//                let StoryBoard = UIStoryboard(name: "Main", bundle: nil)
//                let SVC = StoryBoard.instantiateViewController(withIdentifier: "AppInfoViewController") as! AppInfoViewController
                let SVC = SettingsViewController()
                SVC.hidesBottomBarWhenPushed = true
                navigationController?.pushViewController(SVC, animated: true)
            case 5:
                let vc = JumpMeasuringViewController()
                vc.hidesBottomBarWhenPushed = true
                vc.modalPresentationStyle = .fullScreen
                navigationController?.present(vc, animated: true)
            case 6:
                let vc = MethodSelectionViewController()
                vc.hidesBottomBarWhenPushed = true
                navigationController?.pushViewController(vc, animated: true)
            default:
                print("ouch")
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        //loadUserInfo()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        let textAttributes = [NSAttributedString.Key.foregroundColor:Constants.lightColour]
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes
        self.navigationController?.navigationBar.tintColor = Constants.lightColour
    }

}
