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
    
    var dataSource: ProfileDataSource!
    
    var subscriptions = Set<AnyCancellable>()

    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        showFirstMessage()
        initDataSource()
        initViewModel()
        initDisplay()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        display.frame = getViewableFrameWithBottomSafeArea()
        view.addSubview(display)
    }

    // MARK: - Display
    func initDisplay(){
        display.moreButton.addTarget(self, action: #selector(showMore(_:)), for: .touchUpInside)
        display.notificationsButton.addTarget(self, action: #selector(showNotifications(_:)), for: .touchUpInside)
        display.groupsButton.addTarget(self, action: #selector(showGroups(_:)), for: .touchUpInside)
    }

    
    // MARK: - Data Source
    func initDataSource() {
        dataSource = .init(collectionView: display.collectionView)
        
        dataSource.updateUserInfo(with: UserDefaults.currentUser)
        
        dataSource.$selectedIndex
            .sink { [weak self] in self?.newSegmentSelected($0) }
            .store(in: &subscriptions)
        
        dataSource.itemSelected
            .sink { [weak self] item in
                switch item {
                case .post(let post):
                    self?.showCommentSection(for: post)
                case .clip(let clip):
                    self?.coordinator?.clipSelected(clip)
                case .workout(let workout):
                    self?.coordinator?.showSavedWorkout(workout)
                default:
                    break
                }
            }
            .store(in: &subscriptions)
        
    }
    
    // MARK: - View Model
    func initViewModel(){
        
        viewModel.postPublisher
            .sink { [weak self] posts in
                if self?.display.selectedIndex == 0 {
                    self?.dataSource.updatePosts(with: posts)
                }
            }
            .store(in: &subscriptions)
        
        viewModel.clipPublisher
            .sink { [weak self] clips in
                if self?.display.selectedIndex == 1 {
                    self?.dataSource.updateClips(with: clips)
                }
            }
            .store(in: &subscriptions)
        
        viewModel.savedWorkouts
            .sink { [weak self] workouts in
                if self?.display.selectedIndex == 2 {
                    self?.dataSource.updateWorkouts(with: workouts)
                }
            }
            .store(in: &subscriptions)
        
        viewModel.fetchPostRefs()
        viewModel.fetchClipKeys()
        viewModel.fetchWorkoutKeys()

    }
    
    
    // MARK: - Actions
    func newSegmentSelected(_ newIndex: Int) {
        display.selectedIndex = newIndex
        switch newIndex {
        case 0:
            dataSource.updatePosts(with: viewModel.postPublisher.value)
        case 1:
            dataSource.updateClips(with: viewModel.clipPublisher.value)
            break
        case 2:
            dataSource.updateWorkouts(with: viewModel.savedWorkouts.value)
        default:
            break
        }
    }
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
