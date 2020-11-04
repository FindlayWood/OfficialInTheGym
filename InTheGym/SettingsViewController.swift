//
//  SettingsViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 31/07/2019.
//  Copyright © 2019 FindlayWood. All rights reserved.
//

import UIKit
import Firebase
import SCLAlertView

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // new look with tableview for 1.4
    @IBOutlet var tableview:UITableView!
    
    // array holding labels in tableview
    var tableContent = ["Provide Feedback", "App Information", "Contact us", "Reset Password", "Logout"]
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableview.rowHeight = 80
        tableview.isScrollEnabled = false
        
        
        hideKeyboardWhenTappedAround()
        
        
    }
    

    
    
    func logout(){
        // edit appearance of alert
        let appearance = SCLAlertView.SCLAppearance(
            showCircularIcon: false
        )
        // new logout alert with new update
        let alert = SCLAlertView(appearance: appearance)
        alert.addButton("Yes", backgroundColor: #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1), textColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)) {
            do{
                try Auth.auth().signOut()
            }
            catch let signOutError as NSError{
                print("Error signing out: %@", signOutError)
            }
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let initial = storyboard.instantiateInitialViewController()
            UIApplication.shared.keyWindow?.rootViewController = initial
        }
        alert.showWarning("Logout?", subTitle: "Are you sure you want to logout?", closeButtonTitle: "No", colorStyle: 0xe01212, colorTextButton: 0xfcfcfc)
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.textColor = .white
        cell.backgroundColor = #colorLiteral(red: 0, green: 0.4618991017, blue: 1, alpha: 1)
        cell.selectionStyle = .none
        cell.textLabel?.text = tableContent[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableContent.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row{
        case 0:
            let StoryBoard = UIStoryboard(name: "Main", bundle: nil)
            let SVC = StoryBoard.instantiateViewController(withIdentifier: "FeedbackViewController") as! FeedbackViewController
            navigationController?.pushViewController(SVC, animated: true)
            
        case 1:
            let StoryBoard = UIStoryboard(name: "Main", bundle: nil)
            let SVC = StoryBoard.instantiateViewController(withIdentifier: "AppInfoViewController") as! AppInfoViewController
            navigationController?.pushViewController(SVC, animated: true)
        case 2:
            let StoryBoard = UIStoryboard(name: "Main", bundle: nil)
            let SVC = StoryBoard.instantiateViewController(withIdentifier: "AppInfoViewController") as! AppInfoViewController
            navigationController?.pushViewController(SVC, animated: true)
        case 3:
            let email = (Auth.auth().currentUser?.email!)!
            
            let appearance = SCLAlertView.SCLAppearance(
                showCircularIcon: false
            )
            let alert = SCLAlertView(appearance: appearance)
            alert.addButton("Yes", backgroundColor: #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1), textColor: .white) {
                Auth.auth().sendPasswordReset(withEmail: email, completion: nil)
            }
            alert.showError("Reset Password?", subTitle: "We will send you an email with instructions to change your password. Are you Sure?",closeButtonTitle: "NO", colorStyle: 0xe01212, colorTextButton: 0xfcfcfc )
        case 4:
            logout()
    
        default:
            print("ouch")
        }
    }

    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
        let textAttributes = [NSAttributedString.Key.foregroundColor:#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)]
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    }
    



}
