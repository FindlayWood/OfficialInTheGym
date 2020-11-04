//
//  GroupRepsViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 18/04/2020.
//  Copyright © 2020 FindlayWood. All rights reserved.
//

import UIKit

class GroupRepsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    //varibales from previous pages containing info on exercise
    var sets: String = ""
    var exercise: String = ""
    var type: String = ""
    
    @IBOutlet weak var tableview:UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Reps"
        
        self.tableview.rowHeight = 65
        
    }
    
    //loading tableview
    //number of rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    //displaying each row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        var x = 0
        if indexPath.row == 0{
            cell.textLabel?.text = "Max"
        }
        else{
            while (x<22) {
                cell.textLabel?.text = "\(indexPath.row)"
                x = x + 1
            }
        }
        
        cell.textLabel?.textColor = .darkGray
        cell.textLabel?.font = .boldSystemFont(ofSize: 22)
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    //selecting each row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //if weights carry on to weights page
        if type == "weights"{
            let StoryBoard = UIStoryboard(name: "Main", bundle: nil)
            let SVC = StoryBoard.instantiateViewController(withIdentifier: "GroupWeightViewController") as! GroupWeightViewController
            SVC.exercise = self.exercise
            SVC.sets = self.sets
            if indexPath.row == 0{
                SVC.reps = "Max"
            }else{
                SVC.reps = "\(indexPath.row)"
            }
            self.navigationController?.pushViewController(SVC, animated: true)
            
        }else{
            // new update will send user to distance page instead
            let StoryBoard = UIStoryboard(name: "Main", bundle: nil)
            let SVC = StoryBoard.instantiateViewController(withIdentifier: "GroupDistanceViewController") as! GroupDistanceViewController
            SVC.exercise = self.exercise
            SVC.sets = self.sets
            if indexPath.row == 0{
                SVC.reps = "Max"
            }else{
                SVC.reps = "\(indexPath.row)"
            }
            self.navigationController?.pushViewController(SVC, animated: true)
            
            //if cardio upload exercise
            /*let dictData = ["exercise": self.exercise,
                            "sets": self.sets,
                            "reps": "\(indexPath.row + 1)"]
            GroupAddViewController.groupExercises.append(dictData)*/
            
            
            /*let alert = UIAlertController(title: "Added!", message: "Exercise has been added to the list.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (UIAlertAction) in
                let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
                self.navigationController?.popToViewController(viewControllers[viewControllers.count - 5], animated: true)
            }))
            self.present(alert, animated: true, completion: nil)*/
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.tintColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)
        let textAttributes = [NSAttributedString.Key.foregroundColor:#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)]
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes
    }

}
