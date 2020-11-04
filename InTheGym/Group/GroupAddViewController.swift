//
//  GroupAddViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 18/04/2020.
//  Copyright © 2020 FindlayWood. All rights reserved.
//

import UIKit
import Firebase
import SCLAlertView
import EmptyDataSet_Swift

class GroupAddViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, EmptyDataSetSource, EmptyDataSetDelegate {
    
    //page outlets
    @IBOutlet weak var titleField:UITextField!
    @IBOutlet weak var tableview:UITableView!
    
    //database reference
    var DBRef:DatabaseReference!
    var ActRef:DatabaseReference!
    
    //current userID
    let userID = Auth.auth().currentUser!.uid
    
    //queue to control order of events
    let myGroup = DispatchGroup()
    
    //list of players from previous page
    var players = [String]()
    
    //number of workouts set
    var workoutsCount:Int!
    
    //public array to hold exercises
    static var groupExercises :[[String:String]] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideKeyboardWhenTappedAround()
        
        DBRef = Database.database().reference().child("Workouts")
        ActRef = Database.database().reference()
        
        tableview.emptyDataSetSource = self
        tableview.emptyDataSetDelegate = self
        tableview.tableFooterView = UIView()
        
        
        self.tableview.layer.cornerRadius = 10
        
        self.navigationItem.title = "Group Workout"
        

    }
    

    @IBAction func savePressed(_ sender:UIButton){
        //load workouts for every player **update** no need to do this anymore
        //add new workout to list **update** no need because of childbyautoid
        //upload new list **update** just upload new workout to list
        //use dispatch queue to loop through players
        //loop through usernames and add workout
        if titleField.text == ""{
            // new alert
            // new alert
            let alert = SCLAlertView()
            alert.showWarning("OOPS!", subTitle: "Please enter a title.", closeButtonTitle: "Ok")
            
        }else if GroupAddViewController.groupExercises.count == 0{
            
            // new alert
            let alert = SCLAlertView()
            alert.showWarning("OOPS!", subTitle: "You must enter at least one exercise. Add exercises by tapping the Add Exercise button.", closeButtonTitle: "Ok")
            
        }
        else{
            let username = AdminActivityViewController.username
            let exerciseData = ["title": titleField.text!,
                                "completed": false,
                                "exercises": GroupAddViewController.groupExercises,
                                "coach":username] as [String : Any]
            myGroup.enter()
            for player in players{
                DBRef.child(player).childByAutoId().setValue(exerciseData)
            }
            self.myGroup.leave()
            
            myGroup.notify(queue: DispatchQueue.main) {
                let actData = ["time":ServerValue.timestamp(),
                "type":"Set Workout",
                "message":"You created a group workout."] as [String:AnyObject]
                
                self.ActRef.child("users").child(self.userID).child("activities").childByAutoId().setValue(actData)
                self.titleField.text = ""
                GroupAddViewController.groupExercises.removeAll()
                self.tableview.reloadData()
                
                // new alert
                let alert = SCLAlertView()
                alert.showSuccess("Group Upload!", subTitle: "This workout has been uploaded and the group of players can now view it.", closeButtonTitle: "Ok")
                
                self.workoutsCount += self.players.count
                self.ActRef.child("users").child(self.userID).child("NumberOfWorkouts").setValue(self.workoutsCount)
                
                
            }
        
        
        }
    }
    
    //function for updating the number of workouts set
    func loadNumberOfWorkouts(){
        ActRef.child("users").child(userID).child("NumberOfWorkouts").observeSingleEvent(of: .value) { (snapshot) in
            let count = snapshot.value as? Int ?? 0
            self.workoutsCount = count
        }
    }
    
    //organising the tableview
    
    //number of rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return GroupAddViewController.groupExercises.count
    }
    
    //what is displayed in each row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.text = GroupAddViewController.groupExercises[indexPath.row]["exercise"]
        cell.isUserInteractionEnabled = false
        return cell
    }
    
    //deleting a row
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            GroupAddViewController.groupExercises.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .left)
        }
    }
    
    // displaying the emptydataset
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = "Add an Exercise"
        let attrs = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .headline)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = "Tap the button above to add the first exercise."
        let attrs = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .body)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadNumberOfWorkouts()
        self.tableview.reloadData()
        navigationController?.navigationBar.tintColor = .white
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    
    
    
}
