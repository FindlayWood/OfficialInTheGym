//
//  SetsViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 07/07/2019.
//  Copyright © 2019 FindlayWood. All rights reserved.
//

import UIKit

class SetsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var sets = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"]
    
    var exercise: String = ""
    var type: String = "weights"
    
    @IBOutlet weak var tableview:UITableView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        print(exercise)
        self.navigationItem.title = "Sets"
        
        self.tableview.rowHeight = 65
        

        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.text = sets[indexPath.row] as String
        cell.textLabel?.textColor = .darkGray
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 22)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sets.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let StoryBoard = UIStoryboard(name: "Main", bundle: nil)
        let SVC = StoryBoard.instantiateViewController(withIdentifier: "RepsViewController") as! RepsViewController
        
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
