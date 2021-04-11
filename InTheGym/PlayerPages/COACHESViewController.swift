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
    var coaches = [Users]()
    
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
        
        loadCoaches()

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return coaches.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! PlayerInfoCell
        //cell.coachName.text = "Phil Jackson"
        cell.coachName.text = coaches[indexPath.row].firstName! + " " + coaches[indexPath.row].lastName!
        cell.coachUsername.text = coaches[indexPath.row].username
        cell.coachEmail.text = coaches[indexPath.row].email
        cell.backgroundColor = #colorLiteral(red: 0.9364961361, green: 0.9364961361, blue: 0.9364961361, alpha: 1)
        cell.layer.cornerRadius = 8
        cell.layer.borderWidth = 0
        cell.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let profile = storyboard.instantiateViewController(withIdentifier: "PublicTimelineViewController") as! PublicTimelineViewController
        profile.user = coaches[indexPath.row]
        self.navigationController?.pushViewController(profile, animated: true)
    }
    
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
    
    // emptydataset functions
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = "No Coaches"
        let attrs = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .headline)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = "Tell your Coach your username and ask them to send you a request. Once you have accepted their request they will appear here."
        let attrs = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .body)]
        return NSAttributedString(string: str, attributes: attrs)
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
        let myGroup = DispatchGroup()
        let coachRef = Database.database().reference().child("PlayerCoaches").child(userID!)
        coachRef.observeSingleEvent(of: .value) { (snapshot) in
            for child in snapshot.children {
                myGroup.enter()
                UserIDToUser.transform(userID: (child as AnyObject).key) { (coach) in
                    defer {myGroup.leave()}
                    self.coaches.append(coach)
                }
            }
            myGroup.notify(queue: .main) {
                self.tableview.reloadData()
            }
        }
    }
    

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        let textAttributes = [NSAttributedString.Key.foregroundColor:#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)]
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    }
    

}
