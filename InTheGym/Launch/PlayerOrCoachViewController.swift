//
//  PlayerOrCoachViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 16/11/2020.
//  Copyright © 2020 FindlayWood. All rights reserved.
//

import UIKit
//import SCLAlertView

class PlayerOrCoachViewController: UIViewController, Storyboarded {
    
    weak var coordinator: SignUpCoordinator?
//    weak var coordinator: MainCoordinator?
    
    @IBOutlet var coachView: UIView!
    @IBOutlet var playerView: UIView!
    @IBOutlet var coachButton: UIView!
    @IBOutlet var playerButton: UIView!
    
    @IBOutlet weak var contineButton: UIButton!
    @IBOutlet weak var text: UITextView!
    
    var cornerRadia: CGFloat = 10.0
    var borderColour = Constants.darkColour.cgColor
    var borderWidth: CGFloat = 2.0
    
    let selection = UISelectionFeedbackGenerator()
    
    var isAdmin: Bool!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        text.textAlignment = .center
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
        
//        let warningalert = SCLAlertView()
//        warningalert.showNotice("Verification", subTitle: "New accounts must be verified and you will be sent an email to verify your account before you can login.", closeButtonTitle: "Ok")
        
        selection.prepare()
        contineButton.isHidden = true
        navigationItem.title = "ACCOUNT TYPE"
        text.text = "Choose your ACCOUNT type."
        setUpContinueButton()
    }
    
    @objc fileprivate func coachPressed(){
//        text.text = SignUpMessages.coachMessage
        text.isHidden = false
        coachView.backgroundColor = Constants.darkColour
        playerView.backgroundColor = Constants.lightColour
        isAdmin = true
        self.selection.selectionChanged()
        self.contineButton.setTitle("CONTINUE AS COACH", for: .normal)
        contineButton.isHidden = false
    }
    
    @objc fileprivate func playerPressed(){
//        text.text = SignUpMessages.playerMessage
        text.isHidden = false
        playerView.backgroundColor = Constants.darkColour
        coachView.backgroundColor = Constants.lightColour
        isAdmin = false
        self.selection.selectionChanged()
        self.contineButton.setTitle("CONTINUE AS PLAYER", for: .normal)
        contineButton.isHidden = false
    }
    
    @IBAction func continuePressed(_ sender:UIButton){
        self.selection.selectionChanged()
        self.coordinator?.signUpStepTwo(isAdmin: isAdmin)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
        let textAttributes = [NSAttributedString.Key.foregroundColor:Constants.darkColour]
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes
        self.navigationController?.navigationBar.tintColor = Constants.darkColour
    }
}

extension PlayerOrCoachViewController {
    func setUpContinueButton() {
        contineButton.layer.shadowColor = UIColor.black.cgColor
        contineButton.layer.shadowOffset = CGSize(width: 0, height: 0.0)
        contineButton.layer.shadowRadius = 6.0
        contineButton.layer.shadowOpacity = 1.0
    }
}
