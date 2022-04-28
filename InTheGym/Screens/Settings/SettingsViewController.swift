//
//  SettingsViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 26/04/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import SwiftUI
import Combine

class SettingsViewController: UIViewController {
    
    // MARK: - Properties
    var childContentView = SettingsView()
    
    var viewModel = SettingsViewModel()
    
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        addChildView()
        initViewModel()
    }
    override func viewWillAppear(_ animated: Bool) {
        editNavBarColour(to: .darkColour)
        navigationItem.title = viewModel.navigationTitle
    }


    // MARK: - Swift UI Child View
    func addChildView() {
        childContentView.viewModel = viewModel
        let childView = UIHostingController(rootView: childContentView)
        addChild(childView)
        childView.view.frame = view.bounds
        view.addSubview(childView.view)
        childView.didMove(toParent: self)
    }
    
    // MARK: - View Model
    func initViewModel() {
        viewModel.settingActions
            .sink { [weak self] in self?.tapAction($0)}
            .store(in: &subscriptions)
    }
}
// MARK: - Actions
private extension SettingsViewController {
    func tapAction(_ action: SettingsAction) {
        switch action {
        case .about:
            let Storyboard = UIStoryboard(name: "Main", bundle: nil)
            let SVC = Storyboard.instantiateViewController(withIdentifier: "BestUseMessageViewController") as! BestUseMessageViewController
            self.navigationController?.pushViewController(SVC, animated: true)
        case .icons:
            UIApplication.shared.open(URL(string: Constants.icons8Link)!)
        case .instagram:
            UIApplication.shared.open(URL(string: Constants.instagramLink)!)
        case .website:
            UIApplication.shared.open(URL(string: Constants.websiteString)!)
        case .resetPassword:
            showButtonAlert(title: "Reset Password?", subtitle: "Are you sure you want to reset your password?") { [weak self] in
                self?.viewModel.resetPassword()
            }
        case .logout:
            loggedOut(true)
            showButtonAlert(title: "Logout?", subtitle: "Are you sure you want to logout?") { [weak self] in
                self?.viewModel.logout()
            }
        }
    }
    func resetPassword(_ sent: Bool) {
        if sent {
            showSuccess(subtitle: "Successfully sent reset password email.")
        } else {
            showError()
        }
    }
    func loggedOut(_ success: Bool) {
        if success {
            FirebaseAPI.shared().dispose()
            LikesAPIService.shared.LikedPostsCache.removeAll()
            ViewController.admin = nil
            ViewController.username = nil
            UserDefaults.standard.removeObject(forKey: UserDefaults.Keys.currentUser.rawValue)
            LikeCache.shared.removeAll()
            ClipCache.shared.removeAll()
            UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: false)
        } else {
            showError()
        }
        
    }
}