//
//  BodyTypeViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 07/07/2019.
//  Copyright © 2019 FindlayWood. All rights reserved.
//

// coaches page
// select body type of exercise

import UIKit

class BodyTypeViewController: UIViewController {
    
    @IBAction func buttonTapped(_ sender:UIButton){
        sender.pulsate()
        let StoryBoard = UIStoryboard(name: "Main", bundle: nil)
        let SVC = StoryBoard.instantiateViewController(withIdentifier: "ExerciseViewController") as! ExerciseViewController
        
        SVC.exerciseType = sender.titleLabel!.text as! String
        
        
        self.navigationController?.pushViewController(SVC, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Body Type"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.tintColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
    }

}
