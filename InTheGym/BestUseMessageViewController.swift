//
//  BestUseMessageViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 02/03/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class BestUseMessageViewController: UIViewController {
    
    @IBOutlet weak var textview:UITextView!


    override func viewDidLoad() {
        super.viewDidLoad()

        textview.text = SettingsMessages.howToMakeMostOfAppMessage
    }
    
    @IBAction func dismissView(_ sender:UIButton){
        self.dismiss(animated: true, completion: nil)
    }

}
