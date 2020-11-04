//
//  COACHESViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 03/10/2020.
//  Copyright © 2020 FindlayWood. All rights reserved.
//

import UIKit
import EmptyDataSet_Swift
import SCLAlertView
import Firebase

class COACHESViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, EmptyDataSetSource, EmptyDataSetDelegate {
    
    // array of coaches, atm just array of strings
    var coaches = [String]()
    
    // array of all coach data
    var coachFullData :[[String:Any]] = []
    
    // outlet to tableview
    @IBOutlet weak var tableview:UITableView!
    
    let userID = Auth.auth().currentUser?.uid
    
    var DBRef:DatabaseReference!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        DBRef = Database.database().reference()
        
        tableview.delegate = self
        tableview.dataSource = self
        tableview.rowHeight = 100
        tableview.backgroundColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)
        tableview.emptyDataSetSource = self
        tableview.emptyDataSetDelegate = self
        tableview.tableFooterView = UIView()

        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return coachFullData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! PlayerInfoCell
        //cell.coachName.text = "Phil Jackson"
        cell.coachName.text = coachFullData[indexPath.row]["name"] as? String
        cell.coachUsername.text = coachFullData[indexPath.row]["username"] as? String
        cell.coachEmail.text = coachFullData[indexPath.row]["email"] as? String
        cell.backgroundColor = #colorLiteral(red: 0.9364961361, green: 0.9364961361, blue: 0.9364961361, alpha: 1)
        cell.layer.cornerRadius = 8
        cell.layer.borderWidth = 0
        cell.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        cell.selectionStyle = .none
        return cell
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let screenSize: CGRect = UIScreen.main.bounds
//        let screenWidth = screenSize.width
//
//        let appearance = SCLAlertView.SCLAppearance(
//            kWindowWidth: screenWidth - 40, showCircularIcon: false
//        )
//// TODO: add delete coach function on button below
//        let alert = SCLAlertView(appearance: appearance)
//        alert.addButton("Delete Coach") {
//            print("deleting \(self.coachFullData[indexPath.row]["username"] ?? "COACH")...")
//        }
//        alert.showError("Coach", subTitle: "\(coachFullData[indexPath.row]["username"] ?? "COACH") is one of your coaches. They can view all your workouts and create new ones. You can remove them if you like below.", closeButtonTitle: "Cancel")
//    }
    
    // header for tableview
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 50))
        

        let infoButton = UIButton(frame: CGRect(x: 105, y: 5, width: headerView.frame.height-10, height: headerView.frame.height-10))
        infoButton.setImage(#imageLiteral(resourceName: "help-button"), for: .normal)
        infoButton.addTarget(self, action: #selector(showCoachMessage), for: .touchUpInside)
        

        let label = UILabel()
        label.frame = CGRect.init(x: 5, y: 5, width: headerView.frame.width-10, height: headerView.frame.height-10)
        label.text = "Coaches"
        label.font = UIFont(name: "menlo", size: 25) // my custom font
        label.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1) // my custom colour

        headerView.addSubview(label)
        headerView.addSubview(infoButton)
        headerView.backgroundColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)

        return headerView
    }

// TODO: make this alert delete a coach from a player
    @objc func showCoachMessage(){
        let screenSize: CGRect = UIScreen.main.bounds
        let screenWidth = screenSize.width
        
        let appearance = SCLAlertView.SCLAppearance(
            kWindowWidth: screenWidth - 40, showCircularIcon: true
        )
        let alert = SCLAlertView(appearance: appearance)
        alert.showInfo("Your Coaches", subTitle: "Below is a table of all the coaches you have accepted requests from. All these coaches can view all of your workouts and set you workouts. They can also view your activity and PBs.", closeButtonTitle: "Got It!", circleIconImage: UIImage(named: "coach_icon"))
    }
    
    func loadCoaches(){
        coaches.removeAll()
        coachFullData.removeAll()
        DBRef.child("users").child(userID!).child("coaches").observe(.childAdded) { (snapshot) in
            if let snap = snapshot.value as? String{
                self.coaches.append(snap)
                self.DBRef.child("users").child(snap).observe(.value) { (snapshot) in
                    if let snap = snapshot.value as? [String:Any]{
                        let username = snap["username"] as? String
                        let email = snap["email"] as? String
                        let first = snap["firstName"] as? String
                        let last = snap["lastName"] as? String
                        let coachData = ["name": first! + " " + last!,
                                         "username": username!,
                                         "email": email!
                        ]
                        self.coachFullData.append(coachData)
                        self.tableview.reloadData()
                    }
                }
            }
        }
    }
    

    override func viewWillAppear(_ animated: Bool) {
        loadCoaches()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    

}
