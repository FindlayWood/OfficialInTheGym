//
//  PlayerOrCoachViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 16/11/2020.
//  Copyright © 2020 FindlayWood. All rights reserved.
//

import UIKit
import SCLAlertView

class PlayerOrCoachViewController: UIViewController {
    
    @IBOutlet var coachView:UIView!
    @IBOutlet var playerView:UIView!
    @IBOutlet var coachButton:UIView!
    @IBOutlet var playerButton:UIView!
    
    var cornerRadia : CGFloat = 10.0
    var borderColour = UIColor.black.cgColor
    var borderWidth : CGFloat = 2.0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        coachView.layer.cornerRadius = cornerRadia
        coachView.layer.borderColor = borderColour
        coachView.layer.borderWidth = borderWidth
        playerView.layer.cornerRadius = cornerRadia
        playerView.layer.borderColor = borderColour
        playerView.layer.borderWidth = borderWidth
        
        coachButton.isUserInteractionEnabled = false
        playerButton.isUserInteractionEnabled = false
        
        let coachTap = UITapGestureRecognizer(target: self, action: #selector(coachPressed))
        coachView.addGestureRecognizer(coachTap)
        
        let playerTap = UITapGestureRecognizer(target: self, action: #selector(playerPressed))
        playerView.addGestureRecognizer(playerTap)
        
        let warningalert = SCLAlertView()
        warningalert.showNotice("Verification", subTitle: "New accounts must be verified and you will be sent an email to verify your account before you can login.", closeButtonTitle: "Ok")
        
    }
    
    @objc fileprivate func coachPressed(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let svc = storyboard.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
        svc.admin = true
        self.navigationController?.pushViewController(svc, animated: true)
    }
    
    @objc fileprivate func playerPressed(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let svc = storyboard.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
        svc.admin = false
        self.navigationController?.pushViewController(svc, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
        let textAttributes = [NSAttributedString.Key.foregroundColor:#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)]
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    }
    


}
