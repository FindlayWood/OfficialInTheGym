//
//  AdminPlayersViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 29/07/2019.
//  Copyright © 2019 FindlayWood. All rights reserved.
//

import UIKit
import Firebase
import SCLAlertView
import EmptyDataSet_Swift

class AdminPlayersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, EmptyDataSetSource, EmptyDataSetDelegate {
    
    @IBOutlet weak var tableview:UITableView!
    @IBOutlet weak var activityIndicator:UIActivityIndicatorView!
    @IBOutlet weak var segmentControl:UISegmentedControl!
    
    var DBref:DatabaseReference!
    var userRef:DatabaseReference!
    
    static var players = [Users]()
    var users = [Users]()
    
    // varibale to check for first time
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    // rows to display in the tableview
    var rowsToDisplay : [[String:AnyObject]] = []
    // new version of timeline posts
    var playerFeed : [[String:AnyObject]] = []
    var timeline : [[String:AnyObject]] = []
    
    // self user id
    let userID = Auth.auth().currentUser!.uid

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // added for new feed
        segmentControl.addTarget(self, action: #selector(handleSegmentChange), for: .valueChanged)
        let NotSelectedTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 12)]
        let SelectedTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 12)]
        segmentControl.setTitleTextAttributes(NotSelectedTextAttributes, for: .normal)
        segmentControl.setTitleTextAttributes(SelectedTextAttributes, for: .selected)
        
        tableview.emptyDataSetSource = self
        tableview.emptyDataSetDelegate = self
        tableview.estimatedRowHeight = 84
        tableview.rowHeight = UITableView.automaticDimension
        tableview.backgroundColor = Constants.lightColour
        tableview.register(UINib(nibName: "UserCell", bundle: nil), forCellReuseIdentifier: "UserCell")
        tableview.register(UINib(nibName: "TimelineActivityTableViewCell", bundle: nil), forCellReuseIdentifier: "TimelineActivityTableViewCell")
        
        fetchPlayers()
        loadFeed()
    }
    
    // added for new feed
    @objc fileprivate func handleSegmentChange(){

        self.tableview.reloadData()

    }
    
    @IBAction func addPressed(_ sender:UIButton){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let addPage = storyboard.instantiateViewController(withIdentifier: "AddPlayerViewController") as! AddPlayerViewController
        addPage.modalTransitionStyle = .coverVertical
        addPage.modalPresentationStyle = .fullScreen
        self.navigationController?.present(addPage, animated: true, completion: nil)
    }
    
    
    func fetchPlayers(){
        self.activityIndicator.hidesWhenStopped = true
        self.activityIndicator.startAnimating()
        let userID = Auth.auth().currentUser!.uid
        let myGroup = DispatchGroup()
        var tempPlayers = [Users]()
        let playerRef = Database.database().reference().child("CoachPlayers").child(userID)
        playerRef.observe(.value) { (snapshot) in
            if snapshot.exists(){
                for child in snapshot.children{
                    myGroup.enter()
                    UserIDToUser.transform(userID: (child as AnyObject).key) { (user) in
                        tempPlayers.append(user)
                        myGroup.leave()
                    }
                    myGroup.notify(queue: .main){
                        AdminPlayersViewController.players = tempPlayers
                        self.activityIndicator.stopAnimating()
                        self.tableview.reloadData()
                    }
                }
                
            }else{
                self.activityIndicator.stopAnimating()
            }
        }
        
    }
    // loading public feed
    func loadFeed(){
        //feed.removeAll()
        var initialLoad = true
        let playerFeedRef = Database.database().reference().child("Public Feed").child(userID)
        playerFeedRef.observe(.childAdded, with: { (snapshot) in
            if let snap = snapshot.value as? [String:AnyObject]{
                self.playerFeed.insert(snap, at: 0)
            }
            
            if initialLoad == false{
                self.handleSegmentChange()

            }
            
        }, withCancel: nil)
        
        playerFeedRef.observeSingleEvent(of: .value) { (snapshot) in

            initialLoad = false
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch segmentControl.selectedSegmentIndex{
        case 0:
            return AdminPlayersViewController.players.count
        case 1:
            return playerFeed.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch segmentControl.selectedSegmentIndex{
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as! PlayerTableViewCell
            cell.name.text = AdminPlayersViewController.players[indexPath.row].firstName! + " " +  AdminPlayersViewController.players[indexPath.row].lastName!
            cell.username.text = AdminPlayersViewController.players[indexPath.row].username
            if let purl = AdminPlayersViewController.players[indexPath.row].profilePhotoURL{
                DispatchQueue.global(qos: .background).async {
                    let url = URL(string: purl)
                    let data = NSData(contentsOf: url!)
                    let image = UIImage(data: data! as Data)
                    DispatchQueue.main.async {
                        cell.profilePhoto.image = image
                    }
                }
            }else{
                cell.profilePhoto.image = UIImage(named: "player_icon")
            }
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TimelineActivityTableViewCell", for: indexPath) as! TimelineActivityTableViewCell
            cell.type.text = playerFeed[indexPath.row]["type"] as? String
            cell.message.text = playerFeed[indexPath.row]["message"] as? String
            let time =  playerFeed[indexPath.row]["time"] as? TimeInterval
            let date = Date(timeIntervalSince1970: time!/1000)
            cell.time.text = "\(date.timeAgo()) ago"
            let image = playerFeed[indexPath.row]["type"] as? String
            cell.activityImage.image = UIImage(named: image!)
            return cell
        default:
            break
        }
        
        let cell = self.tableview.dequeueReusableCell(withIdentifier: "UserCell") as! PlayerTableViewCell
        cell.name.text = AdminPlayersViewController.players[indexPath.row].firstName! + " " +  AdminPlayersViewController.players[indexPath.row].lastName!
        cell.username.text = AdminPlayersViewController.players[indexPath.row].username
        if let purl = AdminPlayersViewController.players[indexPath.row].profilePhotoURL{
            DispatchQueue.global(qos: .background).async {
                let url = URL(string: purl)
                let data = NSData(contentsOf: url!)
                let image = UIImage(data: data! as Data)
                DispatchQueue.main.async {
                    cell.profilePhoto.image = image
                }
            }
        }else{
            cell.profilePhoto.image = UIImage(named: "player_icon")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if segmentControl.selectedSegmentIndex == 0{
            let StoryBoard = UIStoryboard(name: "Main", bundle: nil)
            let SVC = StoryBoard.instantiateViewController(withIdentifier: "PlayerViewController") as! PlayerViewController
            
            let currentUser = AdminPlayersViewController.players[indexPath.row]
            SVC.firstNameString = currentUser.firstName!
            SVC.lastNameString = currentUser.lastName!
            SVC.userNameString = currentUser.username!
            SVC.userEmailString = currentUser.email!
            SVC.workoutsCompletedInt = currentUser.numberOfCompletes!
            SVC.playerID = currentUser.uid
            
            self.navigationController?.pushViewController(SVC, animated: true)
        }

    }
    
    // emptydataset functions
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        var str = ""
        switch segmentControl.selectedSegmentIndex {
        case 0:
            str = "No Players"
        case 1:
            str = "No Player Feed"
        default:
            break
        }
        
        let attrs = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .headline)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        var str = ""
        switch segmentControl.selectedSegmentIndex {
        case 0:
            str = "Click the plus button in the top right to send a request to a player. If they accept the request they will then appear here."
        case 1:
            str = "When your players complete activities within the app they will then appear here."
        default:
            break
        }

        let attrs = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .body)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    // working on displaying message for the first time
    // function
    override func viewDidAppear(_ animated: Bool) {
         if(!appDelegate.hasLaunchedPlayers){
            //set hasAlreadyLaunched to false
            appDelegate.setLaunchedPlayers()
            //display user agreement license
            // get width of screen to adjust alert appearance
            let screenSize: CGRect = UIScreen.main.bounds
            let screenWidth = screenSize.width
            
            let appearance = SCLAlertView.SCLAppearance(
                kWindowWidth: screenWidth - 40 )

            let alert = SCLAlertView(appearance: appearance)
            alert.showInfo("PLAYERS", subTitle: "This page will display all of your players. Players will need to accept your request before they appear on this page. You can send requests on the ADDPLAYER page. You can tap on a player to get more info about them as well as being able to set a workout for them, view all their previous workouts and view their PBs. You can delete a player from your team by swiping left on their name. Enjoy!", closeButtonTitle: "GOT IT!", colorStyle: 0x347aeb, animationStyle: .bottomToTop)
        }
    }

}
