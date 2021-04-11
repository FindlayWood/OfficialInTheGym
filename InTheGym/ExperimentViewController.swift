//
//  ExperimentViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 10/02/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class ExperimentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableview:UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableview.register(UINib(nibName: "WorkoutCell", bundle: nil), forCellReuseIdentifier: "WorkoutCell")
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: "WorkoutCell") as! TimeLineTableViewCell
        cell.profileImage.image = UIImage(named: "coach_icon")
        cell.username.text = "Big Barry"
        cell.time.text = "12 June 15:40"
        return cell
    }



}
