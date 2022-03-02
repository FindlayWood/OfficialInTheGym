//
//  MyProfileViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 31/03/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit
import SCLAlertView
import Combine

class MyProfileViewController: UIViewController {
    
    var coordinator: MyProfileCoordinator?
    
    // MARK: - Properties
    var display = MyProfileView()

    var viewModel = MyProfileViewModel()
    
    var dataSource: MyProfileDataSource!
    
    var subscriptions = Set<AnyCancellable>()

    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        showFirstMessage()
        initDataSource()
        
        initViewModel()
        initUI()
//        initRefreshControl()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        display.frame = getViewableFrameWithBottomSafeArea()
        view.addSubview(display)
    }

    
    func initUI(){
        display.configure(with: UserDefaults.currentUser)

    }
    
    // MARK: - Data Source
    func initDataSource() {
        dataSource = .init(tableView: display.tableview)
        
        dataSource.optionSelected
            .sink { [weak self] option in
                switch option {
                case .groups:
                    self?.coordinator?.showGroups()
                case .notifications:
                    self?.coordinator?.showNotifications()
                case .savedWorkouts:
                    self?.coordinator?.showSavedWorkouts()
                case .createdWorkouts:
                    self?.coordinator?.showCreatedWorkouts()
                case .scores:
                    self?.coordinator?.showScores()
                case .edit:
//                    self?.coordinator?.editProfile(profileImage: UIImage(), profileBIO: "", delegate: self)
                    break
                case .more:
                    self?.coordinator?.showMoreInfo()
                }
            }
            .store(in: &subscriptions)
        
        dataSource.postSelected
            .sink { [weak self] in self?.showCommentSection(for: $0)}
            .store(in: &subscriptions)
        
        dataSource.userTapped
            .sink { [weak self]in self?.viewModel.getUser(from: $0) }
            .store(in: &subscriptions)
        
        dataSource.workoutTapped
            .sink { [weak self] in self?.viewModel.getWorkout(from: $0) }
            .store(in: &subscriptions)
        
        dataSource.likeButtonTapped
            .sink { [weak self] in self?.viewModel.likeCheck($0) }
            .store(in: &subscriptions)
    }
    
    // MARK: - View Model
    func initViewModel(){
        
        viewModel.postPublisher
            .sink { [weak self] in self?.dataSource.updatePosts(with: $0) }
            .store(in: &subscriptions)
        
        viewModel.followerCountPublisher
            .dropFirst()
            .sink { [weak self] in self?.display.setFollowerCount(to: $0)}
            .store(in: &subscriptions)
        
        viewModel.followingCountPublisher
            .dropFirst()
            .sink { [weak self] in self?.display.setFollowingCount(to: $0)}
            .store(in: &subscriptions)
        
        viewModel.workoutSelected
            .sink { [weak self] in self?.coordinator?.showWorkout($0) }
            .store(in: &subscriptions)
        
        viewModel.savedWorkoutSelected
            .sink { [weak self] in self?.coordinator?.showSavedWorkout($0) }
            .store(in: &subscriptions)
        
        viewModel.userSelected
            .sink { [weak self] in self?.coordinator?.showUser(user: $0) }
            .store(in: &subscriptions)
        
        viewModel.reloadListener
            .sink { [weak self] in self?.dataSource.reloadPost($0)}
            .store(in: &subscriptions)
        
        viewModel.fetchPostRefs()
        viewModel.getFollowerCount()


    }
    
    // MARK: - Actions
    func showCommentSection(for post: post) {
        coordinator?.showCommentSection(post: post, with: viewModel.reloadListener)
    }

    
//    // MARK: - Refresh Control
//    func initRefreshControl(){
//        refreshControl = UIRefreshControl()
//        refreshControl.tintColor = .white
//        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
////        self.tableview.refreshControl = refreshControl
//    }
//
//    @objc func handleRefresh(){
//        viewModel.followerCount()
//        viewModel.fetchData()
//    }
    
    @IBAction func editProfile(_ sender:UIButton) {

    }
    
    @IBAction func showFollowers(_ sender:UIButton){
        coordinator?.showFollowers(true)
    }
    
    @IBAction func showFollowing(_ sender:UIButton){
        coordinator?.showFollowers(false)
    }

}

// extension for first time message
extension MyProfileViewController {
    func showFirstMessage() {
        if UIApplication.isFirstProfileLaunch() {

            let screenSize: CGRect = UIScreen.main.bounds
            let screenWidth = screenSize.width
            
            let appearance = SCLAlertView.SCLAppearance(
                kWindowWidth: screenWidth - 40 )

            let alert = SCLAlertView(appearance: appearance)
            alert.showInfo("MY PROFILE!", subTitle: FirstTimeMessages.myPRofileMessage, closeButtonTitle: "GOT IT!", colorStyle: 0x347aeb, animationStyle: .bottomToTop)
        }
    }
}

extension MyProfileViewController {
    
    @objc func removeIcon(){
        self.tabBarController?.tabBar.items?[3].badgeValue = nil
    }
}
