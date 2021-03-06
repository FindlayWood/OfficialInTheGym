//
//  PlayerActivityViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 30/07/2019.
//  Copyright © 2019 FindlayWood. All rights reserved.
//

//***playerpage***

import UIKit
import Firebase
import SCLAlertView

class PlayerActivityViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableview:UITableView!
    
    // players username, coaches username, coach uid
    static var username:String!
    static var coachName:String!
    static var coachID:String!
    
    var activities : [[String:AnyObject]] = []
    
    var DBref:DatabaseReference!
    var UserRef:DatabaseReference!
    var PostRef:DatabaseReference!
    
    // varibale to check for first time
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableview.rowHeight = UITableView.automaticDimension
        self.tableview.estimatedRowHeight = 90
        self.tableview.tableFooterView = UIView()
        
        let userID = Auth.auth().currentUser?.uid
        
        DBref = Database.database().reference().child("Activities").child(userID!)
        UserRef = Database.database().reference().child("users").child(userID!)
        UserRef.child("username").observeSingleEvent(of: .value) { (snapshot) in
            PlayerActivityViewController.username = snapshot.value as? String
        }
        PostRef = Database.database().reference()
        
        loadActivities() 
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dateStamp = self.activities[indexPath.row]["time"] as? TimeInterval
        let date = NSDate(timeIntervalSince1970: dateStamp!/1000)
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        let final = formatter.string(from: date as Date)
        
        if activities[indexPath.row]["type"] as? String == "post"{
            //tableview.rowHeight = 180
            let cell = self.tableview.dequeueReusableCell(withIdentifier: "cell2") as! ActivityTableViewCell
            
            let coachID = activities[indexPath.row]["posterID"] as? String
     
            self.PostRef.child("users").child(coachID!).child("profilePhotoURL").observeSingleEvent(of: .value) { (snapshot) in
                guard let imageURL = snapshot.value else{
                    print("no profile pic")
                    cell.profilePhoto.image = UIImage(named: "coach_icon")
                    return
                }
                
                DispatchQueue.global(qos: .background).async {
                    let url = URL(string: imageURL as! String)
                    let data = NSData(contentsOf: url!)
                    let image = UIImage(data: data! as Data)
                    DispatchQueue.main.async {
                        cell.profilePhoto.image = image
                        cell.profilePhoto.layer.cornerRadius = cell.profilePhoto.bounds.width / 2.0
                    }
                }
            }
            cell.postTime.text = final
            cell.username.text = activities[indexPath.row]["username"] as? String
            cell.postText.text = activities[indexPath.row]["message"] as? String
            return cell
        }
        else{
            
            let cell = self.tableview.dequeueReusableCell(withIdentifier: "cell") as! ActivityTableViewCell
            //tableview.rowHeight = 90
            cell.backgroundColor = .white
            let type = self.activities[indexPath.row]["type"] as? String
            cell.type.text = type
            cell.time.text = final
            cell.message.text = self.activities[indexPath.row]["message"] as? String
            cell.pic.image = UIImage(named: type!)
            return cell

        }
    }
    
    func loadActivities(){
        //activities.removeAll()
        var initialLoad = true
        self.DBref.observe(.childAdded, with: { (snapshot) in
            if let snap = snapshot.value as? [String:AnyObject]{
                self.activities.insert(snap, at: 0)
            }
            
            if initialLoad == false{
                self.tableview.reloadData()
            }
            
        }, withCancel: nil)
        
        self.DBref.observeSingleEvent(of: .value) { (_) in
            self.tableview.reloadData()
            initialLoad = false
        }
    }
        
    override func viewWillAppear(_ animated: Bool) {
        loadActivities()
        
        tableview.reloadData()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    // working on displaying message for the first time
    // function
    override func viewDidAppear(_ animated: Bool) {
         if(!appDelegate.hasAlreadyLaunched){
            //set hasAlreadyLaunched to false
            appDelegate.sethasAlreadyLaunched()
            //display user agreement license
            // get width of screen to adjust alert appearance
            let screenSize: CGRect = UIScreen.main.bounds
            let screenWidth = screenSize.width
            
            let appearance = SCLAlertView.SCLAppearance(
                kWindowWidth: screenWidth - 40 )

            let alert = SCLAlertView(appearance: appearance)
            alert.showInfo("Welcome!", subTitle: "Welcome to InTheGym!, You have signed up as a Player which means a coach will need to add you to their 'team'. Then they will be able to set workouts which you will be able to view and complete. So let your Coach know your username and wait for them to send you a request. You can view your Coach requests in the MYINFO page. In the mean time you can set your PBs in the MYINFO page. Thanks for signing up. Enjoy!", closeButtonTitle: "GOT IT!", colorStyle: 0x347aeb, animationStyle: .bottomToTop)
        }
    }

}
