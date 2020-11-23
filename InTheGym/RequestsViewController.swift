//
//  RequestsViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 13/07/2019.
//  Copyright © 2019 FindlayWood. All rights reserved.
//

// request page, for a player viewing requests from a coach

import UIKit
import Firebase
import Flurry_iOS_SDK
import SCLAlertView
import EmptyDataSet_Swift

class RequestsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, EmptyDataSetDelegate, EmptyDataSetSource {
    
    // usernames of coaches who sent requests
    var requesters = [String]()
    var username : String = ""
    
    // uid of coaches who sent requests
    var requestKeys = [String]()
    var currentRequested = [String]()
    
    // array of current accepted users
    var accepted = [String]()
    var activities : [[String:AnyObject]] = []
    
    //database reference
    var DBRef:DatabaseReference!
    var FeedRef:DatabaseReference!
    
    //user id
    let userID = Auth.auth().currentUser?.uid
    
    //outlet to tableview
    @IBOutlet weak var tableview:UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Requests"
        navigationController?.setNavigationBarHidden(false, animated: true)
        tableview.rowHeight = 120
        
        DBRef = Database.database().reference().child("users")
        
        self.tableview.emptyDataSetSource = self
        self.tableview.emptyDataSetDelegate = self
        self.tableview.tableFooterView = UIView()
        
    }
    
    
    // displaying tableview info
    // displaying each row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableview.dequeueReusableCell(withIdentifier: "cell") as! RequestTableViewCell
        cell.name.text = requesters[indexPath.row] as String
        cell.acceptButton.tag = indexPath.row
        cell.declineButton.tag = indexPath.row
        cell.acceptButton.addTarget(self, action: "acceptPressed:", for: .touchUpInside)
        cell.declineButton.addTarget(self, action: "declinePressed:", for: .touchUpInside)
        return cell
    }
    
    //number of rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return requesters.count
    }
    
    // fucntion when a request is accepted
    @objc func acceptPressed(_ sender:UIButton){
        Flurry.logEvent("Request Page - Accept pressed.")
        sender.pulsate()
        let adminID = requestKeys[sender.tag]
        PlayerActivityViewController.coachID = adminID
        PlayerActivityViewController.coachName = requesters[sender.tag]
        let userID = Auth.auth().currentUser?.uid
        
        //new alert
        let infowarning = SCLAlertView()
        infowarning.addButton("Yes", backgroundColor: #colorLiteral(red: 0.1745709982, green: 0.8417274746, blue: 0.1462364076, alpha: 1)) {
            self.DBRef.child(adminID).child("players").child("requested").observeSingleEvent(of: .value) { (snapshot) in
                    let snap = snapshot.value as? [String]
                    self.currentRequested = snap!
                    let index = self.currentRequested.firstIndex(of: self.username)
                    self.currentRequested.remove(at: index!)
                    self.DBRef.child(adminID).child("players").child("requested").setValue(self.currentRequested)
                    let coachName = self.requesters[sender.tag]
// MARK: next section will be to add coach to array rather than single value using ID
                
                self.DBRef.child(userID!).child("coaches").childByAutoId().setValue(adminID)
// section ends here
// still have line below but will need removing
                    //self.DBRef.child(userID!).child("coachName").setValue(coachName)
                    let actData = ["time":ServerValue.timestamp(),
                                   "type":"New Coach",
                                   "message":"You accepted a request from \(self.requesters[sender.tag])."] as [String:AnyObject]
                    //self.activities.insert(actData, at: 0)
                    self.DBRef.child(userID!).child("activities").childByAutoId().setValue(actData)
                    self.requesters.remove(at: sender.tag)
                    self.requestKeys.remove(at: sender.tag)
                    self.tableview.reloadData()
                    
                }
            
            self.DBRef.child(adminID).child("players").child("accepted").childByAutoId().setValue(self.userID)
//                self.DBRef.child(adminID).child("players").child("accepted").observeSingleEvent(of: .value) { (snapshot) in
//                    if let snap = snapshot.value as? [String]{
//                        self.accepted = snap
//                        self.accepted.append(self.userID!)
//                        self.DBRef.child(adminID).child("players").child("accepted").setValue(self.accepted)
//                    }
//                    else{
//                        self.accepted.append(self.userID!)
//                        self.DBRef.child(adminID).child("players").child("accepted").setValue(self.accepted)
//                    }
//
//            }
        }
    
        infowarning.showWarning("Are you Sure?", subTitle: "Are you sure you want to accept \(requesters[sender.tag]) as your new coach?", closeButtonTitle: "No")
        
        /*let alert = UIAlertController(title: "Accept Request", message: "Are you sure you want to accept \(requesters[sender.tag]) as your new Coach?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "YES", style: .default, handler: { (UIAlertAction) in
            self.DBRef.child(adminID).child("players").child("requested").observeSingleEvent(of: .value) { (snapshot) in
                let snap = snapshot.value as? [String]
                self.currentRequested = snap!
                let index = self.currentRequested.firstIndex(of: self.username)
                self.currentRequested.remove(at: index!)
                self.DBRef.child(adminID).child("players").child("requested").setValue(self.currentRequested)
                let coachName = self.requesters[sender.tag]
                self.DBRef.child(userID!).child("coachName").setValue(coachName)
                let actData = ["time":ServerValue.timestamp(),
                               "type":"New Coach",
                               "message":"You accepted a request from \(self.requesters[sender.tag])."] as [String:AnyObject]
                //self.activities.insert(actData, at: 0)
                self.DBRef.child(userID!).child("activities").childByAutoId().setValue(actData)
                self.requesters.remove(at: sender.tag)
                self.requestKeys.remove(at: sender.tag)
                self.tableview.reloadData()
                
            }
            self.DBRef.child(adminID).child("players").child("accepted").observeSingleEvent(of: .value) { (snapshot) in
                if let snap = snapshot.value as? [String]{
                    self.accepted = snap
                    self.accepted.append(self.userID!)
                    self.DBRef.child(adminID).child("players").child("accepted").setValue(self.accepted)
                }
                else{
                    self.accepted.append(self.userID!)
                    self.DBRef.child(adminID).child("players").child("accepted").setValue(self.accepted)
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "NO", style: .destructive, handler: nil))
        self.present(alert, animated: true, completion: nil)*/
    }
    
    // emptydataset functions
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = "No Requests"
        let attrs = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .headline)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = "Tell your Coach your username and ask them to send you a request. Once they have it will then appear here!"
        let attrs = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .body)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    //function when a request is declined
    @objc func declinePressed(_ sender:UIButton){
        Flurry.logEvent("Request Page - decline pressed.")
        sender.pulsate()
        let adminID = requestKeys[sender.tag]
        let userID = Auth.auth().currentUser?.uid
        
        DBRef.child(adminID).child("players").child("requested").observeSingleEvent(of: .value) { (snapshot) in
            let snap = snapshot.value as? [String]
            self.currentRequested = snap!
            let index = self.currentRequested.firstIndex(of: self.username)
            self.currentRequested.remove(at: index!)
            self.DBRef.child(adminID).child("players").child("requested").setValue(self.currentRequested)
            let actData = ["time":ServerValue.timestamp(),
                           "type":"Request Declined",
                           "message":"You declined a request from \(self.requesters[sender.tag])"] as [String:AnyObject]
            //self.activities.insert(actData, at: 0)
            self.DBRef.child(userID!).child("activities").childByAutoId().setValue(actData)
            self.requesters.remove(at: sender.tag)
            self.requestKeys.remove(at: sender.tag)
            self.tableview.reloadData()
        }
    }
    
    // function to load all activities for user
    // no need for this function anymore after update
    /*
    func loadActivities(){
        let userID = Auth.auth().currentUser?.uid
        DBRef.child(userID!).observe(.childAdded, with: { (snapshot) in
            if let snap = snapshot.value as? [String:AnyObject]{
                self.activities.append(snap)
            }
        }, withCancel: nil)
    }*/
    
    override func viewWillAppear(_ animated: Bool) {
        //loadActivities()
    }


}
