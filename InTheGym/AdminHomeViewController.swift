//
//  AdminHomeViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 01/06/2019.
//  Copyright © 2019 FindlayWood. All rights reserved.
//

import UIKit
import Firebase

class AdminHomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var DBref:DatabaseReference!
    var userRef:DatabaseReference!
    
    var players = [String]()
    var users = [Users]()
    
    @IBOutlet weak var tableview:UITableView!
    
    @IBOutlet weak var welcomeLabel:UILabel!
    
    @IBAction func logOut(_ sender: UIButton){
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

    override func viewDidLoad() {
        super.viewDidLoad()
        

        
        let userID = Auth.auth().currentUser?.uid
        
        DBref = Database.database().reference().child("users").child(userID!)
        userRef = Database.database().reference()
        loadPlayers()
        loadUsers()
        
        DBref.child("username").observeSingleEvent(of: .value) { (snapshot) in
            let username = snapshot.value as! String
            self.welcomeLabel.text = "Welcome " + username
        }
        
        self.tableview.rowHeight = 65
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadPlayers()
        loadUsers()
    }
    
    func loadPlayers(){
        DBref.child("players").child("accepted").observeSingleEvent(of: .value) { (snapshot) in
            if let snap = snapshot.value as? [String]{
                self.players = snap
                self.tableview.reloadData()
    
            }
        }
    }
    
    func loadUsers(){
        userRef.child("users").observe(.childAdded, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String:AnyObject]{
                let user = Users()
                user.username = dictionary["username"] as? String
                user.admin = dictionary["admin"] as? Bool
                user.email = dictionary["email"] as? String
                user.fistName = dictionary["firstName"] as? String
                user.lastName = dictionary["lastName"] as? String
                self.users.append(user)
            }
        }, withCancel: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return players.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableview.dequeueReusableCell(withIdentifier: "cell") as! PlayerTableViewCell
        for user in users{
            if players[indexPath.row].contains(user.username!){
                cell.name.text = "\(user.fistName ?? "") \(user.lastName ?? "")"
                cell.username.text = "\(user.username!)"
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let StoryBoard = UIStoryboard(name: "Main", bundle: nil)
        let SVC = StoryBoard.instantiateViewController(withIdentifier: "PlayerViewController") as! PlayerViewController
        
        for user in users{
            if players[indexPath.row].contains(user.username!){
                SVC.userNameString = user.username!
                SVC.userEmailString = user.email!
                SVC.firstNameString = user.fistName ?? ""
                SVC.lastNameString = user.lastName ?? ""
            }
        }
        
        self.navigationController?.pushViewController(SVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            players.remove(at: indexPath.row)
            users.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .left)
            DBref.child("players").setValue(players)
        }
    }
    
    
    

    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }

}
