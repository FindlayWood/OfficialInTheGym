//
//  LaunchPageViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 26/11/2020.
//  Copyright © 2020 FindlayWood. All rights reserved.
//

import UIKit
import SCLAlertView
import Combine
import Firebase

class LaunchPageViewController: UIViewController, Storyboarded {
    // MARK: - Outlets
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    // MARK: - Properties
    weak var coordinator: MainCoordinator?
    var viewModel = LaunchPageViewModel()
    private var subscriptions = Set<AnyCancellable>()
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.tintColor = .white
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        spinner.startAnimating()
        spinner.hidesWhenStopped = true
        initViewModel()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    // MARK: - View Model
    func initViewModel() {
//        viewModel.$user
//            .dropFirst()
//            .sink { [weak self] in self?.receivedUser($0)}
//            .store(in: &subscriptions)
//        viewModel.$checkingError
//            .compactMap { $0 }
//            .sink { [weak self] in self?.receivedCheckingError($0)}
//            .store(in: &subscriptions)
//        viewModel.checkForUserDefault()
    }
}
// MARK: - Actions
private extension LaunchPageViewController {
    func receivedUser(_ user: Users?) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if let user = user {
            if user.admin {
                appDelegate.loggedInCoach()
            } else {
                appDelegate.loggedInPlayer()
            }
        } else {
            appDelegate.nilUser()
        }
    }
    func receivedCheckingError(_ error: checkingForUserError) {
        switch error {
        case .noUser:
            viewModel.user = nil
        case .reloadError:
            showError()
        case .notVerified(let user):
            showNotVerified(to: user)
        }
    }
}
// MARK: - Alerts
private extension LaunchPageViewController {
    func showSuccess(to user: User){
        let alert = SCLAlertView()
        alert.showSuccess("Sent", subTitle: "Verification email sent to \(user.email ?? "NA")")
    }
    func showNotVerified(to user: User) {
        let screenSize: CGRect = UIScreen.main.bounds
        let screenWidth = screenSize.width

        let appearance = SCLAlertView.SCLAppearance(
            kWindowWidth: screenWidth - 40,
            showCloseButton: false)

        let alertview = SCLAlertView(appearance: appearance)
        alertview.addButton("Resend Verification Email") {
            user.sendEmailVerification()
            self.showSuccess(to: user)
        }
        alertview.addButton("OK") {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.nilUser()
        }

        alertview.showWarning("Verify", subTitle: "You must verify your account from the email we sent you. Then we can log you in straight away.")
    }
    func showError() {
        let screenSize: CGRect = UIScreen.main.bounds
        let screenWidth = screenSize.width

        let appearance = SCLAlertView.SCLAppearance(
            kWindowWidth: screenWidth - 40 )

        let alertview = SCLAlertView(appearance: appearance)
        alertview.addButton("OK") {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.nilUser()
        }

        alertview.showError("Error", subTitle: "There was an error.")
    }
}
