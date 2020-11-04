//
//  GroupSetsViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 18/04/2020.
//  Copyright © 2020 FindlayWood. All rights reserved.
//

import UIKit

class GroupSetsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //array from 1 to 10
    var sets = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"]
    
    //variable from previous page holding exercise
    var exercise: String = ""
    
    //string set to weights to display reps, changed to mins if cardio selected
    var type: String = "weights"
    
    @IBOutlet weak var tableview:UITableView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Sets"
        
        self.tableview.rowHeight = 65

    }
    
    //loading tableview
    //display each row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.text = sets[indexPath.row] as String
        cell.textLabel?.textColor = .darkGray
        cell.textLabel?.font = .boldSystemFont(ofSize: 22)
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    //number of rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sets.count
    }
    
    //selecting a row and moving to next page
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let StoryBoard = UIStoryboard(name: "Main", bundle: nil)
        let SVC = StoryBoard.instantiateViewController(withIdentifier: "GroupRepsViewController") as! GroupRepsViewController
        
        SVC.sets = sets[indexPath.row]
        SVC.exercise = self.exercise
        SVC.type = self.type
        
        self.navigationController?.pushViewController(SVC, animated: true)
    }
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.tintColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)
        let textAttributes = [NSAttributedString.Key.foregroundColor:#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)]
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes
    }

}
