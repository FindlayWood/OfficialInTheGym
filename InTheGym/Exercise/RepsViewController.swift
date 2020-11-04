//
//  RepsViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 07/07/2019.
//  Copyright © 2019 FindlayWood. All rights reserved.
//

import UIKit

class RepsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var sets: String = ""
    var exercise: String = ""
    var type: String = ""
    
    @IBOutlet weak var tableview:UITableView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Reps"
        
        self.tableview.rowHeight = 65
        
        // commenting out this for distance
        /*if type == "weights"{
            self.navigationItem.title = "Reps"
        }else{
            self.navigationItem.title = "Minutes"
        }*/
        

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 21
    }
    
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
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 22)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if type == "weights"{
            let StoryBoard = UIStoryboard(name: "Main", bundle: nil)
            let SVC = StoryBoard.instantiateViewController(withIdentifier: "WeightViewController") as! WeightViewController
            SVC.exercise = self.exercise
            SVC.sets = self.sets
            if indexPath.row == 0{
                SVC.reps = "Max"
            }else{
                SVC.reps = "\(indexPath.row)"
            }
            
            self.navigationController?.pushViewController(SVC, animated: true)
            
        }else{
            // new to add distance page rather than add
            
            let StoryBoard = UIStoryboard(name: "Main", bundle: nil)
            let SVC = StoryBoard.instantiateViewController(withIdentifier: "DistanceViewController") as! DistanceViewController
            SVC.exercise = self.exercise
            SVC.sets = self.sets
            if indexPath.row == 0{
                SVC.reps = "Max"
            }else{
                SVC.reps = "\(indexPath.row)"
            }
            self.navigationController?.pushViewController(SVC, animated: true)
            
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.tintColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)
        let textAttributes = [NSAttributedString.Key.foregroundColor:#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)]
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes
    }
}
