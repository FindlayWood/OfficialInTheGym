//
//  PublicTimelineViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 23/03/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class PublicTimelineViewController: UIViewController {
    
    // MARK: - Coordinator
    weak var coordinator: UserProfileCoordinator?

    // MARK: - Properties
    var display = PublicTimelineView()
    
    var viewModel = PublicTimelineViewModel()
    
    var dataSource: ProfileDataSource!
    
    private var subscriptions = Set<AnyCancellable>()
    

    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        initDataSource()
        initViewModel()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        display.frame = getFullViewableFrame()
        view.addSubview(display)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        editNavBarColour(to: .lightColour)
        navigationItem.title = viewModel.user.username
    }
    
    // MARK: - Data Source
    func initDataSource() {
        dataSource = .init(collectionView: display.collectionView)
        
        dataSource.updatePublicUserInfo(with: viewModel.user)
        
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

        
        viewModel.fetchPosts()
        viewModel.getFollowerCount()
        viewModel.checkFollowing()
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
        coordinator?.showCommentSection(for: post, with: viewModel.reloadListener)
    }
    @IBAction func follow(_ sender: UIButton) {
        viewModel.follow()
    }
    @IBAction func showCreatedWorkouts(_ sender:UIButton){
        coordinator?.showCreatedWorkouts(for: viewModel.user)

    }
}

