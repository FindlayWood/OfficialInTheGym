//
//  AppInfoViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 30/04/2020.
//  Copyright © 2020 FindlayWood. All rights reserved.
//

import UIKit

class AppInfoViewController: UIViewController {
    
    @IBOutlet weak var version:UILabel!
    @IBOutlet weak var message:UITextView!
    
    let constants = Constants()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appVersion = constants.appVersion
        self.version.text = "App Version: \(appVersion)"
        self.message.text = SettingsMessages.howToMakeMostOfAppMessage

        // Do any additional setup after loading the view.
    }
    
    @IBAction func urlPressed(_ sender:UIButton){
        if let url = URL(string: "https://icons8.com") {
            UIApplication.shared.open(url)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
        let textAttributes = [NSAttributedString.Key.foregroundColor:#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)]
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    }


}
