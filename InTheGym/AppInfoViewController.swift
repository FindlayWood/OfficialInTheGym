//
//  AppInfoViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 30/04/2020.
//  Copyright © 2020 FindlayWood. All rights reserved.
//

import UIKit
import SCLAlertView
import Firebase

class AppInfoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, Storyboarded {
    

    @IBOutlet weak var tableview:UITableView!
    
    let constants = Constants()
    
    let titles = ["App Version", "About", "Feedback", "Icons", "Instagram", "Website", "Contact Us", "Reset Password", "Logout"]
    let descriptions = ["Keep the app up to date for all the latest features.\n", "", "", "Our awesome icons are provided by Icons8. They have a great service for icons, check them out above!\n", "", "", "The best way to contact us is through either our feedback section or via Instagram. We have an email that can be contacted for further enquiries. officialinthegym@gmail.com \n", "If you wish to reset your password we will send you an email with instructions on how to do so.", "Logging out from the app will mean you will not be automatically logged in when you open the app until you log in again."]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableview.delegate = self
        tableview.dataSource = self
        tableview.register(UINib(nibName: "AppInformationTableViewCell", bundle: nil), forCellReuseIdentifier: "AppInformationTableViewCell")
        tableview.register(UINib(nibName: "AppInformationTwoTableViewCell", bundle: nil), forCellReuseIdentifier: "AppInformationTwoTableViewCell")
        tableview.tableFooterView = UIView()
//        tableview.separatorStyle = .none
//        tableview.separatorColor = .clear
        tableview.separatorInset = .zero
        tableview.layoutMargins = .zero

        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 || indexPath.row == 3 || indexPath.row == 6 || indexPath.row == 7 || indexPath.row == 8{
            let cell = tableView.dequeueReusableCell(withIdentifier: "AppInformationTableViewCell", for: indexPath) as! AppInformationTableViewCell
            cell.titleText.text = titles[indexPath.row]
            cell.descriptionText.text = descriptions[indexPath.row]
            if indexPath.row == 0 {
                cell.additionalInfo.text = constants.appVersion
            } else {
                cell.additionalInfo.text = ""
            }
            if indexPath.row == titles.count - 1{
                cell.titleText.textColor = .red
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AppInformationTwoTableViewCell", for: indexPath) as! AppInformationTwoTableViewCell
            cell.titleText.text = titles[indexPath.row]
            if indexPath.row == titles.count - 1{
                cell.titleText.textColor = .red
            }
            return cell
        }
        
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let StoryBoard = UIStoryboard(name: "Main", bundle: nil)
        switch indexPath.row{
        case 1:
            let SVC = StoryBoard.instantiateViewController(withIdentifier: "BestUseMessageViewController") as! BestUseMessageViewController
            SVC.modalPresentationStyle = .fullScreen
            SVC.modalTransitionStyle = .coverVertical
            self.navigationController?.present(SVC, animated: true, completion: nil)
        case 2:
            let SVC = StoryBoard.instantiateViewController(withIdentifier: "FeedbackViewController") as! FeedbackViewController
            navigationController?.pushViewController(SVC, animated: true)
        case 3:
            urlPressed()
        case 4:
            UIApplication.shared.open(URL(string: Constants.instagramLink)!)
        case 5:
            UIApplication.shared.open(URL(string: Constants.websiteString)!)
        case 7:
            resetPassword()
        case 8:
            logout()
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemGray5
        } else {
            // Fallback on earlier versions
        }
        return view
    }
    
    
    
    func urlPressed(){
        if let url = URL(string: "https://icons8.com") {
            UIApplication.shared.open(url)
        }
    }
    
    func resetPassword(){
        // edit appearance of alert
        let appearance = SCLAlertView.SCLAppearance(
            showCircularIcon: false
        )
        // new logout alert with new update
        let alert = SCLAlertView(appearance: appearance)
        alert.addButton("Yes", backgroundColor: #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1), textColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)) {
            let email = Auth.auth().currentUser?.email
            Auth.auth().sendPasswordReset(withEmail: email!, completion: { (error) in
                if let error = error{
                    print(error.localizedDescription)
                    let alert = SCLAlertView()
                    alert.showError("Error", subTitle: "Sorry there was an error trying to send you the reset password email. Please try again.")
                } else {
                    let alert = SCLAlertView()
                    alert.showSuccess("Email Sent!", subTitle: "We have sent you an email to reset your password. Follow the instructions in the email to reset your password.", closeButtonTitle: "Ok")
                }
            })
        }
        alert.showWarning("Reset Password?", subTitle: "Are you sure you want to reset your password?", closeButtonTitle: "No", colorStyle: 0xe01212, colorTextButton: 0xfcfcfc)

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
                FirebaseAPI.shared().dispose()
                LikesAPIService.shared.LikedPostsCache.removeAll()
                ViewController.admin = nil
                ViewController.username = nil
                //PlayerTimelineViewModel.apiService.removeObserver(withHandle: PlayerTimelineViewModel.handle)
                
        

//                let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                let initial = storyboard.instantiateInitialViewController()
//                UIApplication.shared.keyWindow?.rootViewController = initial
                UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: false, completion: nil)
                
            }
            catch let signOutError as NSError{
                print("Error signing out: %@", signOutError)
            }

        }
        alert.showWarning("Logout?", subTitle: "Are you sure you want to logout?", closeButtonTitle: "No", colorStyle: 0xe01212, colorTextButton: 0xfcfcfc)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
        let textAttributes = [NSAttributedString.Key.foregroundColor: Constants.lightColour]
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes
        self.navigationController?.navigationBar.tintColor = Constants.lightColour
        self.navigationItem.title = "Settings"
    }


}
