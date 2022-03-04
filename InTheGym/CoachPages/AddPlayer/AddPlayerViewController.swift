//
//  AddPlayerViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 30/06/2019.
//  Copyright © 2019 FindlayWood. All rights reserved.
//

import UIKit
import Combine
import SCLAlertView

class AddPlayerViewController: UIViewController, Storyboarded {
    
    // MARK: - Properties
    var viewModel = AddPlayerViewModel()
    
    private var subscriptions = Set<AnyCancellable>()
    
    //activity indicator when loading
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // varibale to check for first time
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    let haptic = UINotificationFeedbackGenerator()
    
    @IBOutlet weak var playerfield: UITextField!
    @IBOutlet weak var addButton: UIButton!
    
    @IBAction func addTapped(_ sender: UIButton){
        viewModel.checkAlreadyCoach()
    }
    
    @IBAction func backPressed(_ sender: UIButton){
        self.dismiss(animated: true, completion: nil)
    }

    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        playerfield.delegate = self
        playerfield.tintColor = .white
        haptic.prepare()
        activityIndicator.hidesWhenStopped = true
        initViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    // MARK: - View Model
    func initViewModel() {
        
        viewModel.$isLoading
            .sink { [weak self] in self?.setLoading($0)}
            .store(in: &subscriptions)
        
        viewModel.$canAdd
            .sink { [weak self] in self?.setButton(to: $0) }
            .store(in: &subscriptions)
        
        viewModel.successfullySentRequest
            .sink { [weak self] success in
                self?.activityIndicator.stopAnimating()
                if success { self?.alertSuccessRequestSent()}
                else { self?.alertError() }
            }
            .store(in: &subscriptions)
        
        viewModel.nilUserError
            .sink { [weak self] _ in self?.alertNoUserFound()}
            .store(in: &subscriptions)
        
        viewModel.alreadyPlayer
            .sink { [weak self] _ in self?.alertPlayer()}
            .store(in: &subscriptions)
        
        viewModel.requestExists
            .sink { [weak self] _ in self?.alertRequestSent()}
            .store(in: &subscriptions)
    }
    
    //MARK: - Actions
    func setButton(to enabled: Bool) {
        addButton.addViewShadow(with: enabled ? .darkColour : .clear)
        addButton.isEnabled = enabled
//        if enabled {
//            addButton.addViewShadow(with: .darkColour)
//        } else {
//            addButton.addViewShadow(with: .clear)
//        }
    }
    func setLoading(_ loading: Bool) {
        if loading {
            activityIndicator.startAnimating()
            addButton.isUserInteractionEnabled = false
        } else {
            activityIndicator.stopAnimating()
            addButton.isUserInteractionEnabled = true
        }
    }

    // MARK: - Alerts
    func alertSuccessRequestSent() {
        haptic.notificationOccurred(.success)
        let alert = SCLAlertView()
        alert.showSuccess("Sent!", subTitle: "A request has been sent to this user!. You will have to wait until they accept it before you can assign them workouts, add them to groups and monitor their workout data.", closeButtonTitle: "ok", animationStyle: .topToBottom)
        
        playerfield.text = ""
        viewModel.updateSearchModel(with: "")
    }
    
    func alertNoUserFound(){
        haptic.notificationOccurred(.error)
        let alert = SCLAlertView()
        alert.showError("Error!", subTitle: "This username doesn't exist. Be sure to check with your players what their usernames are. Be careful when typing, they are case sensitive.", closeButtonTitle: "ok", animationStyle: .topToBottom)
        
        playerfield.text = ""
        viewModel.updateSearchModel(with: "")
    }
    
    func alertRequestSent(){
        haptic.notificationOccurred(.warning)
        let alert = SCLAlertView()
        alert.showWarning("Already Sent!", subTitle: "You have already sent a request to this player. You will have to wait until they accept it before you can assign them workouts, add them to groups and monitor their workout data.", closeButtonTitle: "ok", animationStyle: .topToBottom)
        
        playerfield.text = ""
        viewModel.updateSearchModel(with: "")
    }
    
    func alertPlayer(){
        haptic.notificationOccurred(.warning)
        let alert = SCLAlertView()
        alert.showError("Already Accepted!", subTitle: "This player has already accepted a request from you. You will find them on the PLAYERS tab. You can assign them workouts, add them to groups and monitor their workout data from there.", closeButtonTitle: "ok", animationStyle: .topToBottom)
        
        playerfield.text = ""
        viewModel.updateSearchModel(with: "")
    }
    
    func alertError(){
        haptic.notificationOccurred(.warning)
        let alert = SCLAlertView()
        alert.showError("Error!", subTitle: "There was an error. Please try again.", closeButtonTitle: "ok", animationStyle: .topToBottom)
        
        playerfield.text = ""
        viewModel.updateSearchModel(with: "")
    }
    

}

extension AddPlayerViewController {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string).trimTrailingWhiteSpaces()
        viewModel.updateSearchModel(with: newString)
        return true
    }
}
