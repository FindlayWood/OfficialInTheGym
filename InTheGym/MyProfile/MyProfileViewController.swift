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
    
    // MARK: - Child VC
    var postsChildVC = PostsChildViewController()
    
    var clipsChildVC = MyClipsChildViewController()
    
    var workoutsChildVC = SavedWorkoutsChildViewController()

    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        showFirstMessage()
        initDataSource()
        
        initViewModel()
        initChildPublishers()
        initUI()
        initSubscriptions()
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
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addToContainer(vc: postsChildVC)
    }

    
    func initUI(){
        display.infoView.configure(with: UserDefaults.currentUser)
        display.moreButton.addTarget(self, action: #selector(showMore(_:)), for: .touchUpInside)
        display.notificationsButton.addTarget(self, action: #selector(showNotifications(_:)), for: .touchUpInside)
        display.groupsButton.addTarget(self, action: #selector(showGroups(_:)), for: .touchUpInside)
    }
    
    // MARK: - Add Child
    func addToContainer(vc controller: UIViewController) {
        addChild(controller)
        display.addSubview(controller.view)
        controller.view.frame = display.containerView.frame
        controller.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        controller.didMove(toParent: self)
    }
    
    func removeFromContainer(vc controller: UIViewController) {
        controller.willMove(toParent: nil)
        controller.view.removeFromSuperview()
        controller.removeFromParent()
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
//            .sink { [weak self] in self?.dataSource.updatePosts(with: $0) }
            .sink { [weak self] in self?.postsChildVC.dataSource.updateTable(with: $0) }
            .store(in: &subscriptions)
        
        viewModel.savedWorkouts
            .sink { [weak self] in self?.workoutsChildVC.dataSource.updateTable(with: $0) }
            .store(in: &subscriptions)
        
        viewModel.followerCountPublisher
            .dropFirst()
            .sink { [weak self] in self?.display.infoView.setFollowerCount(to: $0)}
            .store(in: &subscriptions)
        
        viewModel.followingCountPublisher
            .dropFirst()
            .sink { [weak self] in self?.display.infoView.setFollowingCount(to: $0)}
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
        viewModel.fetchWorkoutKeys()

    }
    
    // MARK: - Child Publihsers
    func initChildPublishers() {
        
        postsChildVC.dataSource.scrollPublisher
            .sink { [weak self] offset in
                guard let self = self else {return}
                self.display.scroll(to: offset)
                self.resizeFrame(for: self.postsChildVC)
            }
            .store(in: &subscriptions)
        
        clipsChildVC.dataSource.scrollPublisher
            .sink { [weak self] offset in
                guard let self = self else {return}
                self.display.scroll(to: offset)
                self.resizeFrame(for: self.clipsChildVC)
            }
            .store(in: &subscriptions)
        
        workoutsChildVC.dataSource.scrollPublisher
            .sink { [weak self] offset in
                guard let self = self else {return}
                self.display.scroll(to: offset)
                self.resizeFrame(for: self.workoutsChildVC)
            }
            .store(in: &subscriptions)
        
        postsChildVC.dataSource.postSelcted
            .sink { [weak self] in self?.showCommentSection(for: $0)}
            .store(in: &subscriptions)
        
        postsChildVC.dataSource.userTapped
            .sink { [weak self]in self?.viewModel.getUser(from: $0) }
            .store(in: &subscriptions)
        
        postsChildVC.dataSource.workoutTapped
            .sink { [weak self] in self?.viewModel.getWorkout(from: $0) }
            .store(in: &subscriptions)
        
        postsChildVC.dataSource.likeButtonTapped
            .sink { [weak self] in self?.viewModel.likeCheck($0) }
            .store(in: &subscriptions)
    
        workoutsChildVC.dataSource.workoutSelected
            .sink { [weak self] in self?.coordinator?.showSavedWorkout($0)}
            .store(in: &subscriptions)
        
        clipsChildVC.dataSource.clipSelected
            .sink { [ weak self] in self?.coordinator?.clipSelected($0)}
            .store(in: &subscriptions)
        
    }
    
    func resizeFrame(for controller: UIViewController) {
        UIView.animate(withDuration: 0.3) {
            controller.view.frame = self.display.containerView.frame
            controller.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        }
    }
    
    // MARK: - Actions
    func showCommentSection(for post: post) {
        coordinator?.showCommentSection(post: post, with: viewModel.reloadListener)
    }
    
    @objc func showMore(_ sender: UIButton) {
        coordinator?.showMoreInfo()
    }
    @objc func showNotifications(_ sender: UIButton) {
        coordinator?.showNotifications()
    }
    @objc func showGroups(_ sender: UIButton) {
        coordinator?.showGroups()
    }
    
    // MARK: - Subscriptions
    func initSubscriptions() {
        display.segmentControl.selectedIndex
            .sink { [weak self] in self?.segmentChanged(to: $0) }
            .store(in: &subscriptions)
    }
    
    // MARK: - Switch Segment
    func segmentChanged(to index: Int) {
//        viewModel.selectedIndex = index
        if index == 0 {
            removeFromContainer(vc: clipsChildVC)
            removeFromContainer(vc: workoutsChildVC)
            addToContainer(vc: postsChildVC)
        } else if index == 1  {
            removeFromContainer(vc: postsChildVC)
            removeFromContainer(vc: workoutsChildVC)
            addToContainer(vc: clipsChildVC)
        } else if index == 2 {
            removeFromContainer(vc: postsChildVC)
            removeFromContainer(vc: clipsChildVC)
            addToContainer(vc: workoutsChildVC)
        }
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
