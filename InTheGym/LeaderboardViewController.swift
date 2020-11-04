//
//  LeaderboardViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 19/02/2020.
//  Copyright © 2020 FindlayWood. All rights reserved.
//

import UIKit
import Firebase

class LeaderboardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    //outlet to tableview and segment control
    @IBOutlet weak var tableview:UITableView!
    @IBOutlet weak var segment:UISegmentedControl!
    
    
    //2 references to database, first for loading players, second for loading leaderboard
    var DBRef:DatabaseReference!
    var LBoardRef:DatabaseReference!
    var PBRef:DatabaseReference!
    var userRef:DatabaseReference!
    
    //getting userid and username of current user(which will be a coach)
    var username = AdminActivityViewController.username
    
    //array to store the players usernames in
    var players = [String]()
    
    //array for bench press max, squat max and pull up max
    var pressMax = [(String, Double)]()
    var squatMax = [(String,Double)]()
    var pullMax = [(String,Double)]()
    
    lazy var rowsToDisplay = pressMax
    
    var users = [Users]()
    
    let myGroup = DispatchGroup()

    override func viewDidLoad() {
        super.viewDidLoad()
        let userID = Auth.auth().currentUser?.uid
        
        //creating refernce point to load players
        DBRef = Database.database().reference().child("users").child(userID!)
        userRef = Database.database().reference()
        segment.addTarget(self, action: #selector(handleSegmentChange), for: .valueChanged)
        
    }
    
    @objc fileprivate func handleSegmentChange(){
        switch segment.selectedSegmentIndex {
        case 0:
            pressMax = pressMax.sorted(by: { $0.1 > $1.1 })
            rowsToDisplay = pressMax
        case 1:
            squatMax = squatMax.sorted(by: { $0.1 > $1.1 })
            rowsToDisplay = squatMax
        default:
            pullMax = pullMax.sorted(by: { $0.1 > $1.1 })
            rowsToDisplay = pullMax
        }
        
        tableview.reloadData()
    }
    
    
    func loadPlayers(){
        DBRef.child("players").child("accepted").observeSingleEvent(of: .value) { (snapshot) in
            if let snap = snapshot.value as? [String]{
                self.players = snap
                self.loadUsers()
                self.tableview.reloadData()
            }
        }
    }
    
    func loadUsers(){
        for player in players{
            myGroup.enter()
            userRef.child("users").child(player).observe(.value) { (snapshot) in
                if let snap = snapshot.value as? [String:AnyObject]{
                    let user = Users()
                    user.username = snap["username"] as? String
                    user.email = snap["email"] as? String
                    user.firstName = snap["firstName"] as? String
                    user.lastName = snap["lastName"] as? String
                    self.users.append(user)
                    self.myGroup.leave()
                }
            }
        }
        myGroup.notify(queue: DispatchQueue.main) {
            self.getUserScores()
        }
    }
    
    func getUserScores(){
        for user in users{
            myGroup.enter()
            let username = user.username!
            userRef.child("PBs").child(username).child("Bench1").observeSingleEvent(of: .value) { (snapshot) in
                let snap = snapshot.value as? String
                if snap != nil{
                    let num = Double(snap!)
                    self.pressMax.append((username, num ?? 0))
                }else{
                    self.pressMax.append((username, 0))
                }
                self.myGroup.leave()
                
            }
            myGroup.enter()
            userRef.child("PBs").child(username).child("Squat1").observeSingleEvent(of: .value) { (snapshot) in
                let snap = snapshot.value as? String
                if snap != nil{
                    let num = Double(snap!)
                    self.squatMax.append((username, num ?? 0))
                }else{
                    self.squatMax.append((username, 0))
                }
                self.myGroup.leave()
            }
            myGroup.enter()
            userRef.child("PBs").child(username).child("PullUpMax").observeSingleEvent(of: .value) { (snapshot) in
                let snap = snapshot.value as? String
                if snap != nil{
                    let num = Double(snap!)
                    self.pullMax.append((username, num ?? 0))
                }else{
                    self.pullMax.append((username, 0))
                }
                self.myGroup.leave()
            }
            
        }
        
        myGroup.notify(queue: DispatchQueue.main) {
            self.tableview.reloadData()
            self.handleSegmentChange()
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowsToDisplay.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableview.dequeueReusableCell(withIdentifier: "cell") as! LeaderboardTableViewCell
        cell.numberLabel.text = "\(indexPath.row + 1)"
        cell.usernameLabel.text = "\(rowsToDisplay[indexPath.row].0)"
        cell.weightLabel.text = "\(rowsToDisplay[indexPath.row].1)"
        return cell
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadPlayers()
        navigationController?.setNavigationBarHidden(false, animated: true)
        let textAttributes = [NSAttributedString.Key.foregroundColor:#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)]
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    }

}
