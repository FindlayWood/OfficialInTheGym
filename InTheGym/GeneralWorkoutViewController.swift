//
//  GeneralWorkoutViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 21/02/2020.
//  Copyright © 2020 FindlayWood. All rights reserved.
//

import UIKit
import Firebase
import SCLAlertView

//this class is for trying to let the coach create a workout that can be given to several players

@available(iOS 13.0, *)
class GeneralWorkoutViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    //outlets for the 2 tableviews
    @IBOutlet weak var tableview1:UITableView!
    @IBOutlet weak var tableview2:UITableView!
    
    //string for yes and no players
    var yesPlayers : [String] = []
    var noPlayers = [String]()
    
    //array for usernames and player id
    var usernames = [String]()
    var playersID = [String]()
    
    //database references
    var DBRef:DatabaseReference!
    var userRef:DatabaseReference!
    
    // varibale to check for first time
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let userID = Auth.auth().currentUser?.uid
        
        DBRef = Database.database().reference().child("users").child(userID!)
        
        
        userRef = Database.database().reference()
        
        tableview1.rowHeight = 45
        tableview2.rowHeight = 45
        tableview1.layer.cornerRadius = 10
        tableview2.layer.cornerRadius = 10

        
    }
    
    //loading tableview
    //number of rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tableview1 {
            return yesPlayers.count
        }else if tableView == tableview2{
            return noPlayers.count
        }
        else {return 0}
    }
    
    //displaying each row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == tableview1 {
            let cell = self.tableview1.dequeueReusableCell(withIdentifier: "cell1") as! GeneralTableViewCell
            cell.name.text = yesPlayers[indexPath.row]
            cell.imagec.image = UIImage(named: "Workout Completed")
            return cell
        }else{
            let cell = self.tableview2.dequeueReusableCell(withIdentifier: "cell2") as! GeneralTableViewCell
            cell.name.text = noPlayers[indexPath.row]
            cell.imagec.image = UIImage(named: "Workout UnCompleted")
            return cell
        }
    }
    
    //selecting each row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == tableview2 {
            yesPlayers.append(noPlayers[indexPath.row])
            noPlayers.remove(at: indexPath.row)
        }
        if tableView == tableview1{
            noPlayers.insert(yesPlayers[indexPath.row], at: 0)
            yesPlayers.remove(at: indexPath.row)
        }
        tableview1.reloadData()
        tableview2.reloadData()
    }
    
    func loadPlayers(){
        self.noPlayers.removeAll()
        self.yesPlayers.removeAll()
        DBRef.child("players").child("accepted").observeSingleEvent(of: .value) { (snapshot) in
            if let snap = snapshot.value as? [String]{
                self.playersID = snap
                self.tableview2.reloadData()
                self.tableview1.reloadData()
                self.loadUsers()
            }
        }
    }
    
    func loadUsers(){
        usernames.removeAll()
        for player in playersID{
            userRef.child("users").child(player).observe(.value) { (snapshot) in
                if let snap = snapshot.value as? [String:AnyObject]{
                    self.usernames.append(snap["username"] as! String)
                    self.noPlayers.append(snap["username"] as! String)
                    self.tableview2.reloadData()
                    self.tableview1.reloadData()
                    
                }
            }
        }
    }
    
    @IBAction func addAll(_ sender:UIButton){
        if noPlayers.isEmpty == false{
            for player in noPlayers{
                yesPlayers.append(player)
            }
            noPlayers.removeAll()
            tableview1.reloadData()
            tableview2.reloadData()
        }
        
    }
    
    
    @IBAction func confirmed(){
        if yesPlayers.isEmpty{
            let alert = SCLAlertView()
            alert.showWarning("OOPS", subTitle: "Make sure there is at least one player in the yes players section to add a workout. Move players between sections by tapping on them.", closeButtonTitle: "Ok")
            
            
        }else{
            let Storyboard = UIStoryboard(name: "Main", bundle: nil)
            let SVC = Storyboard.instantiateViewController(identifier: "GroupAddViewController") as! GroupAddViewController
            SVC.players = self.yesPlayers
            
            self.navigationController?.pushViewController(SVC, animated: true)
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadPlayers()
        tableview2.reloadData()
        tableview1.reloadData()
        navigationController?.setNavigationBarHidden(true, animated: true)
        let textAttributes = [NSAttributedString.Key.foregroundColor:#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)]
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    }

    // working on displaying message for the first time
    // function
    override func viewDidAppear(_ animated: Bool) {
         if(!appDelegate.hasLaunchedGroup){
            //set hasAlreadyLaunched to false
            appDelegate.setLaunchedGroup()
            //display user agreement license
            // get width of screen to adjust alert appearance
            let screenSize: CGRect = UIScreen.main.bounds
            let screenWidth = screenSize.width
            
            let appearance = SCLAlertView.SCLAppearance(
                kWindowWidth: screenWidth - 40 )

            let alert = SCLAlertView(appearance: appearance)
            alert.showInfo("GROUPWORKOUT", subTitle: "This page allows you to set workouts for a group of players. All players will initially appear in the No Players section and to move them into the Yes Players section you just tap on them. Or you can move them all up by tapping Add All. Tapping confirm will then take you to the workout design page which will be added to all the Yes Players. Enjoy!", closeButtonTitle: "GOT IT!", colorStyle: 0x347aeb, animationStyle: .bottomToTop)
        }
    }

}
