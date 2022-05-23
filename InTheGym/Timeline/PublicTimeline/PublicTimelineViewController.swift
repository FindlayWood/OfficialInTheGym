//
//  PublicTimelineViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 23/03/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class PublicTimelineViewController: UIViewController, CustomAnimatingClipFromVC {
    
    // MARK: - Coordinator
    weak var coordinator: UserProfileCoordinator?

    // MARK: - Properties
    var display = PublicTimelineView()
    
    var viewModel = PublicTimelineViewModel()
    
    //    var dataSource: ProfileDataSource!
    var dataSource: ProfileTableViewDataSource!
    
    private var subscriptions = Set<AnyCancellable>()
    
    var selectedCell: ClipCollectionCell?
    var selectedCellImageViewSnapshot: UIView?
    

    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        initDataSource()
        initViewModel()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        display.frame = getFullViewableFrame()
        view.addSubview(display)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        editNavBarColour(to: .lightColour)
        navigationItem.title = viewModel.user.username
    }
    
    // MARK: - Data Source
    func initDataSource() {
//        dataSource = .init(collectionView: display.collectionView)
        dataSource = .init(tableView: display.tableview)
        
        dataSource.updatePublicUserInfo(with: viewModel.user)
        
        dataSource.profileInfoAction
            .sink { [weak self] in self?.profileInfoAction($0)}
            .store(in: &subscriptions)
        
        dataSource.postSelected
            .sink { [weak self] in self?.showCommentSection(for: $0)}
            .store(in: &subscriptions)
        
//        dataSource.$selectedIndex
//            .sink { [weak self] in self?.newSegmentSelected($0) }
//            .store(in: &subscriptions)
        
//        dataSource.cellSelected
//            .sink { [weak self] selectedCellModel in
//                self?.selectedCell = selectedCellModel.selectedCell
//                self?.selectedCellImageViewSnapshot = selectedCellModel.snapshot
//            }
//            .store(in: &subscriptions)
        
//        dataSource.itemSelected
//            .sink { [weak self] item in
//                guard let self = self else {return}
//                switch item {
//                case .post(let post):
//                    self.showCommentSection(for: post)
//                case .clip(let clip):
//                    self.coordinator?.clipSelected(clip, fromViewControllerDelegate: self)
//                case .workout(let workout):
//                    self.coordinator?.showSavedWorkout(workout)
//                default:
//                    break
//                }
//            }
//            .store(in: &subscriptions)
        
        dataSource.userTapped
            .sink { [weak self]in self?.viewModel.getUser(from: $0) }
            .store(in: &subscriptions)
        
        dataSource.workoutTapped
            .sink { [weak self] in self?.viewModel.getWorkout(from: $0) }
            .store(in: &subscriptions)
        
//        dataSource.likeButtonTapped
//            .sink { [weak self] in self?.viewModel.likeCheck($0) }
//            .store(in: &subscriptions)
    }
    

    
    // MARK: - View Model
    func initViewModel(){
        
        viewModel.postPublisher
            .sink { [weak self] in self?.dataSource.updatePosts(with: $0) }
            .store(in: &subscriptions)
        
//        viewModel.clipPublisher
//            .sink { [weak self] clips in
//                if self?.display.selectedIndex == 1 {
//                    self?.dataSource.updateClips(with: clips)
//                }
//            }
//            .store(in: &subscriptions)
//
//        viewModel.savedWorkouts
//            .sink { [weak self] workouts in
//                if self?.display.selectedIndex == 2 {
//                    self?.dataSource.updateWorkouts(with: workouts)
//                }
//            }
//            .store(in: &subscriptions)
        
        viewModel.workoutSelected
            .sink { [weak self] in self?.coordinator?.showWorkout($0) }
            .store(in: &subscriptions)
        
        viewModel.savedWorkoutSelected
            .sink { [weak self] in self?.coordinator?.showSavedWorkout($0) }
            .store(in: &subscriptions)
        
        viewModel.userSelected
            .sink { [weak self] in self?.coordinator?.showUser(user: $0) }
            .store(in: &subscriptions)

        
        viewModel.fetchPosts()
//        viewModel.fetchClipKeys()
//        viewModel.fetchWorkoutKeys()
    }

    
//    // MARK: - Actions
    func profileInfoAction(_ action: ProfileInfoActions) {
        switch action {
        case .followers:
            coordinator?.showUserFollowers(user: viewModel.user)
        case .following:
            coordinator?.showUserFollowers(user: viewModel.user)
        case .clips:
            coordinator?.showUserClips(user: viewModel.user)
        case .savedWorkouts:
            coordinator?.showUserWorkouts(user: viewModel.user)
        }
    }
//    func newSegmentSelected(_ newIndex: Int) {
//        display.selectedIndex = newIndex
//        switch newIndex {
//        case 0:
//            dataSource.updatePosts(with: viewModel.postPublisher.value)
//        case 1:
//            dataSource.updateClips(with: viewModel.clipPublisher.value)
//            break
//        case 2:
//            dataSource.updateWorkouts(with: viewModel.savedWorkouts.value)
//        default:
//            break
//        }
//    }
    func showCommentSection(for post: PostModel) {
        coordinator?.showCommentSection(for: post, with: viewModel.reloadListener)
    }

    @IBAction func showCreatedWorkouts(_ sender:UIButton){
        coordinator?.showCreatedWorkouts(for: viewModel.user)

    }
}
