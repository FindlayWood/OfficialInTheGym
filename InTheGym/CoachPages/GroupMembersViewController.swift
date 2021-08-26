//
//  GroupMembersViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 22/02/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit
import Firebase

class GroupMembersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableview:UITableView!
    
    var groupMembers:[String] = []
    
    var userRef:DatabaseReference!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        userRef = Database.database().reference()

        // Do any additional setup after loading the view.
        tableview.tableFooterView = UIView()
        tableview.rowHeight = 84
        tableview.backgroundColor = Constants.lightColour
        tableview.register(UINib(nibName: "UserCell", bundle: nil), forCellReuseIdentifier: "UserCell")
        
        self.navigationItem.title = "Group Members"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: "UserCell") as! PlayerTableViewCell
        let currentID = groupMembers[indexPath.row]
        userRef.child("users").child(currentID).observe(.value) { (snapshot) in
            if let snap = snapshot.value as? [String:AnyObject]{
                let first = snap["firstName"] as! String
                let last = snap["lastName"] as! String
                cell.name.text = "\(first) \(last)"
                let username = snap["username"] as! String
                cell.username.text = "@\(username)"
                if let imageURL = snap["profilePhotoURL"] as? String{
                    DispatchQueue.global(qos: .background).async {
                        let url = URL(string: imageURL)
                        let data = NSData(contentsOf: url!)
                        let image = UIImage(data: data! as Data)
                        DispatchQueue.main.async {
                            cell.profilePhoto.image = image
                            cell.profilePhoto.layer.cornerRadius = cell.profilePhoto.bounds.width / 2.0
                        }
                    }
                }else{
                    cell.profilePhoto.image = UIImage(named: "player_icon")
                }
            }
        }
        
        
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupMembers.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let playerView = storyboard.instantiateViewController(withIdentifier: "PlayerViewController") as! PlayerViewController
        
        let selectedUserID = groupMembers[indexPath.row]
        
        UserIDToUser.transform(userID: selectedUserID) { (user) in
            playerView.firstNameString = user.firstName
            playerView.lastNameString = user.lastName
            playerView.userNameString = user.username
            playerView.userEmailString = user.email
            playerView.workoutsCompletedInt = user.numberOfCompletes ?? 0
            playerView.playerID = user.uid
            self.navigationController?.pushViewController(playerView, animated: true)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        let textAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes
        self.navigationController?.navigationBar.tintColor = .white
    }
    
}
