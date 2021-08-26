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

class AdminPlayersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, EmptyDataSetSource, EmptyDataSetDelegate, Storyboarded {
    
    var coordinator: PlayersFlow?
    
    @IBOutlet weak var tableview:UITableView!
    @IBOutlet weak var activityIndicator:UIActivityIndicatorView!
    @IBOutlet weak var segmentControl:UISegmentedControl!
    
    var DBref:DatabaseReference!
    var userRef:DatabaseReference!
    var playersRef:DatabaseReference!
    var playersFeedRef:DatabaseReference!
    var handle:DatabaseHandle!
    var feedHandle:DatabaseHandle!
    
    var players = [Users]()
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
    
    //refreshControl for tableview
    var refreshControl:UIRefreshControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        showFirstMessage()
        
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
        tableview.tableFooterView = UIView()
        tableview.separatorStyle = .none
        tableview.separatorColor = .clear
        
        playersRef = Database.database().reference().child("CoachPlayers").child(userID)
        playersFeedRef = Database.database().reference().child("Public Feed").child(userID)
        
        initRefreshControl()
        fetchPlayers()
        //loading()

        
    }
    
    func initRefreshControl(){
        refreshControl = UIRefreshControl()
        refreshControl.tintColor = .white
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        self.tableview.refreshControl = refreshControl
    }
    
    @objc func handleRefresh(){
        self.fetchPlayers()
    }
    
    // added for new feed
    @objc fileprivate func handleSegmentChange(){

        self.tableview.reloadData()

    }
    
    @IBAction func addPressed(_ sender:UIButton){
        coordinator?.addNewPlayer()
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let addPage = storyboard.instantiateViewController(withIdentifier: "AddPlayerViewController") as! AddPlayerViewController
//        addPage.modalTransitionStyle = .coverVertical
//        addPage.modalPresentationStyle = .fullScreen
//        self.navigationController?.present(addPage, animated: true, completion: nil)
    }
    
    func loading(){
        self.activityIndicator.hidesWhenStopped = true
        self.activityIndicator.startAnimating()
        self.tableview.alpha = 0.0
        DatabaseEndpoints.getPlayers(id: self.userID).retreive(expectedReturnType: Users.self) { result in
            switch result{
            case .success(let returnedPlayers):
                self.players = returnedPlayers
                self.activityIndicator.stopAnimating()
                self.tableview.reloadData()
                self.tableview.refreshControl?.endRefreshing()
                UIView.animate(withDuration: 0.2) {
                    self.tableview.alpha = 1.0
                }
            case .failure(let error):
                print(error.localizedDescription)
                self.activityIndicator.stopAnimating()
                self.tableview.reloadData()
                self.tableview.refreshControl?.endRefreshing()
                UIView.animate(withDuration: 0.2) {
                    self.tableview.alpha = 1.0
                }
            }
        }
    }
    
    func fetchPlayers(){
        self.activityIndicator.hidesWhenStopped = true
        self.activityIndicator.startAnimating()
        self.tableview.alpha = 0.0
        
        let myGroup = DispatchGroup()
        var tempPlayers = [Users]()
        //let playerRef = Database.database().reference().child("CoachPlayers").child(userID)
        playersRef.observeSingleEvent(of: .value) { (snapshot) in
            self.players.removeAll()
            if snapshot.exists(){
                for child in snapshot.children{
                    myGroup.enter()
                    UserIDToUser.transform(userID: (child as AnyObject).key) { (user) in
                        tempPlayers.append(user)
                        myGroup.leave()
                    }
                    myGroup.notify(queue: .main){
                        self.players = tempPlayers
                        self.activityIndicator.stopAnimating()
                        self.tableview.reloadData()
                        self.tableview.refreshControl?.endRefreshing()
                        UIView.animate(withDuration: 0.2) {
                            self.tableview.alpha = 1.0
                        }
                    }
                }
                
            }else{
                self.activityIndicator.stopAnimating()
                self.tableview.refreshControl?.endRefreshing()
                UIView.animate(withDuration: 0.2) {
                    self.tableview.alpha = 1.0
                }
            }
        }
        
    }
    // loading public feed
    func loadFeed(){
        //feed.removeAll()
        var initialLoad = true
        //let playerFeedRef = Database.database().reference().child("Public Feed").child(userID)
        feedHandle = playersFeedRef.observe(.childAdded, with: { (snapshot) in
            if let snap = snapshot.value as? [String:AnyObject]{
                self.playerFeed.insert(snap, at: 0)
            }
            
            if initialLoad == false{
                self.handleSegmentChange()

            }
            
        }, withCancel: nil)
        
        playersFeedRef.observeSingleEvent(of: .value) { (snapshot) in

            initialLoad = false
        }
    }
    
    func removeObservers(){
        self.playersFeedRef.removeObserver(withHandle: feedHandle)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch segmentControl.selectedSegmentIndex{
        case 0:
            return self.players.count
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
            cell.name.text = self.players[indexPath.row].firstName + " " +  self.players[indexPath.row].lastName
            cell.username.text = "@" + self.players[indexPath.row].username
            let playerID = self.players[indexPath.row].uid
            ImageAPIService.shared.getProfileImage(for: playerID) { (image) in
                if let image = image{
                    cell.profilePhoto.image = image
                } else {
                    cell.profilePhoto.image = UIImage(named: "player_icon")
                }
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
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if segmentControl.selectedSegmentIndex == 0{
            //let StoryBoard = UIStoryboard(name: "Main", bundle: nil)
            //let SVC = StoryBoard.instantiateViewController(withIdentifier: "PlayerViewController") as! PlayerViewController
            
            let currentUser = self.players[indexPath.row]
            coordinator?.showPlayerInMoreDetail(player: currentUser)
//            SVC.player = currentUser
//            SVC.firstNameString = currentUser.firstName!
//            SVC.lastNameString = currentUser.lastName!
//            SVC.userNameString = currentUser.username!
//            SVC.userEmailString = currentUser.email!
//            SVC.workoutsCompletedInt = currentUser.numberOfCompletes!
//            SVC.playerID = currentUser.uid
//            SVC.hidesBottomBarWhenPushed = true
//
//            self.navigationController?.pushViewController(SVC, animated: true)
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
    
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        return UIImage(named: "player_icon")
    }
    
    func buttonTitle(forEmptyDataSet scrollView: UIScrollView, for state: UIControl.State) -> NSAttributedString? {
        let str = "Add Player"
        let attrs = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .callout)]
        return NSAttributedString(string: str, attributes: attrs)
    }

    func emptyDataSet(_ scrollView: UIScrollView, didTap button: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let addPage = storyboard.instantiateViewController(withIdentifier: "AddPlayerViewController") as! AddPlayerViewController
        addPage.modalTransitionStyle = .coverVertical
        addPage.modalPresentationStyle = .fullScreen
        self.navigationController?.present(addPage, animated: true, completion: nil)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        loadFeed()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.removeObservers()
    }
}

// extension for first time message
extension AdminPlayersViewController {
    func showFirstMessage() {
        if UIApplication.isFirstPlayersLaunch() {

            let screenSize: CGRect = UIScreen.main.bounds
            let screenWidth = screenSize.width
            
            let appearance = SCLAlertView.SCLAppearance(
                kWindowWidth: screenWidth - 40 )

            let alert = SCLAlertView(appearance: appearance)
            alert.showInfo("PLAYERS!", subTitle: FirstTimeMessages.playersMessage, closeButtonTitle: "GOT IT!", colorStyle: 0x347aeb, animationStyle: .bottomToTop)
        }
    }
}
