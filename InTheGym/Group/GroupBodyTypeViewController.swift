//
//  GroupBodyTypeViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 18/04/2020.
//  Copyright © 2020 FindlayWood. All rights reserved.
//

import UIKit

class GroupBodyTypeViewController: UIViewController {

    @IBAction func buttonTapped(_ sender:UIButton){
        sender.pulsate()
        let StoryBoard = UIStoryboard(name: "Main", bundle: nil)
        let SVC = StoryBoard.instantiateViewController(withIdentifier: "GroupExerciseViewController") as! GroupExerciseViewController
        
        SVC.exerciseType = sender.titleLabel!.text as! String
        
        self.navigationController?.pushViewController(SVC, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Body Type"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.tintColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
        let textAttributes = [NSAttributedString.Key.foregroundColor:#colorLiteral(red: 0, green: 0.4618991017, blue: 1, alpha: 1)]
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes
        
    }
    

    

}
