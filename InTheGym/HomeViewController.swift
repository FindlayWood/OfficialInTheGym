//
//  HomeViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 31/05/2019.
//  Copyright © 2019 FindlayWood. All rights reserved.
//

import UIKit
import Firebase

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var logoutButton:UIButton!
    
    @IBOutlet weak var welcomeLabel:UILabel!
    @IBOutlet weak var adminLabel:UILabel!
    @IBOutlet weak var acceptRequestButton:UIButton!
    @IBOutlet weak var coachName:UILabel!
    @IBOutlet weak var tableview:UITableView!
    
    var username:String = ""
    var adminKey:String = ""
    var gotARequest:Bool = false
    var requesters = [String]()
    var requestKeys = [String]()
    var activities : [[String:AnyObject]] = []
    
    var DBref:DatabaseReference!
    var ActRef:DatabaseReference!
    
    @IBAction func logout(_ sender:UIButton){
        sender.pulsate()
        let alert = UIAlertController(title: "Logout", message: "Are you sure you want to logout?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (UIAlertAction) in
            do{
                try Auth.auth().signOut()
            }
            catch let signOutError as NSError{
                print("Error signing out: %@", signOutError)
            }
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let initial = storyboard.instantiateInitialViewController()
            UIApplication.shared.keyWindow?.rootViewController = initial
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func viewWorkouts(_ sender:UIButton){
        sender.pulsate()
        let Storyboard = UIStoryboard(name: "Main", bundle: nil)
        let SVC = Storyboard.instantiateViewController(withIdentifier: "ViewWorkoutViewController") as! ViewWorkoutViewController
        SVC.username = self.username
        self.navigationController?.pushViewController(SVC, animated: true)
        
    }
    
    @IBAction func viewPBs(_ sender:UIButton){
        sender.pulsate()
        let Storyboard = UIStoryboard(name: "Main", bundle: nil)
        let SVC = Storyboard.instantiateViewController(withIdentifier: "PBsViewController") as! PBsViewController
        SVC.username = self.username
        self.navigationController?.pushViewController(SVC, animated: true)
    }
    
    @IBAction func viewRequests(_ sender:UIButton){
        sender.pulsate()
        let Storyboard = UIStoryboard(name: "Main", bundle: nil)
        let SVC = Storyboard.instantiateViewController(withIdentifier: "RequestsViewController") as! RequestsViewController
        SVC.requesters = self.requesters
        SVC.requestKeys = self.requestKeys
        SVC.username = self.username
        self.navigationController?.pushViewController(SVC, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        acceptRequestButton.isHidden = true
        self.tableview.rowHeight = 90
        self.tableview.layer.cornerRadius = 10
        
    
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        DBref = Database.database().reference()
        
        
        let userID = Auth.auth().currentUser?.uid
        ActRef = Database.database().reference().child("users").child(userID!).child("activities")
        
        self.DBref.child("users").child(userID!).child("username").observeSingleEvent(of: .value) { (snapshot) in
            let username = snapshot.value as! String
            self.welcomeLabel.text = "Welcome " + username
            self.username = username
        }
        
    }
    func requests(){
        self.requesters.removeAll()
        self.requestKeys.removeAll()
        var requestCount = 0
        self.DBref.child("users").observe(.childAdded, with: { (snapshot) in
            if let snap = snapshot.value as? [String:Any]{
                if snap["admin"] as! Bool == true{
                    if let playerSnap = snap["players"] as? [String:Any]{
                        if let requests = playerSnap["requested"] as? [String]{
                            if requests.contains(self.username){
                                requestCount = requestCount + 1
                                let coach = snap["username"] as! String
                                self.requesters.append(coach)
                                self.requestKeys.append(snapshot.key)
                                self.adminLabel.text = "you have \(requestCount) new requests"
                                self.acceptRequestButton.isHidden = false
                            }
                            else{
                                self.adminLabel.text = "You don't have any new requests."
                                self.acceptRequestButton.isHidden = true
                            }
                        }
                        else{
                            self.adminLabel.text = "You don't have any new requests."
                            self.acceptRequestButton.isHidden = true
                        }
                    }
                }
            }
        }, withCancel: nil)
    }
    
    func getCoach(){
        let userID = Auth.auth().currentUser?.uid
        
        self.DBref.child("users").child(userID!).child("coachName").observeSingleEvent(of: .value) { (snapshot) in
            if let coach = snapshot.value as? String{
                self.coachName.text = "Your coach is \(coach)"
            }
            else{
                self.coachName.text = "You do not have a coach yet."
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        loadActivities()
        requests()
        getCoach()
        tableview.reloadData()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activities.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableview.dequeueReusableCell(withIdentifier: "cell") as! ActivityTableViewCell
        let dateStamp = self.activities[indexPath.row]["time"] as? TimeInterval
        let date = NSDate(timeIntervalSince1970: dateStamp!/1000)
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        let final = formatter.string(from: date as Date)
        let type = self.activities[indexPath.row]["type"] as? String
        cell.type.text = type
        cell.time.text = final
        cell.message.text = self.activities[indexPath.row]["message"] as? String
        cell.pic.image = UIImage(named: type!)
        
        return cell
    }
    func loadActivities(){
        activities.removeAll()
        self.ActRef.observe(.childAdded, with: { (snapshot) in
            if let snap = snapshot.value as? [String:AnyObject]{
                self.activities.append(snap)
                self.tableview.reloadData()
            }
        }, withCancel: nil)
    }
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
    }

}
