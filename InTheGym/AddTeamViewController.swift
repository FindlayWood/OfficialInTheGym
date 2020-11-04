//
//  AddTeamViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 01/07/2019.
//  Copyright © 2019 FindlayWood. All rights reserved.
//

import UIKit
import Firebase

class AddTeamViewController: UIViewController {
    
    var DBref:DatabaseReference!
    
    @IBOutlet weak var teamname:UITextField!
    
    @IBAction func addPressed(_ sender:Any){
        if teamname.text == ""{
            let alert = UIAlertController(title: "Error!", message: "Passwords do not match", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler:  nil))
            self.present(alert, animated: true, completion: nil)
        }
        else{
            let name = teamname.text!
            self.DBref.setValue(name)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        DBref = Database.database().reference().child("teams")
        
        

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
