//
//  GroupHomePageViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 12/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class GroupHomePageViewController: UIViewController {
    
    // MARK: - Properties
    weak var coordinator: GroupHomeCoordinator?
    
    var display = GroupHomePageView()
    
    var viewModel = GroupHomePageViewModel()
    
    var dataSource: GroupHomePageDataSource!
    
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - View
    override func loadView() {
        view = display
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .darkColour
        initDisplay()
        addNavBarButton()
        initDataSource()
        initViewModel()

    }
    override func viewWillAppear(_ animated: Bool) {
        editNavBarColour(to: .white)
    }
    // MARK: - Display
    func initDisplay() {
        display.tableview.backgroundColor = .darkColour
    }
    
    // MARK: - Nav Bar
    func addNavBarButton() {
        let postButton = UIBarButtonItem(image: UIImage(systemName: "pencil.circle.fill"), style: .plain, target: self, action: #selector(postButtonTapped))
        navigationItem.rightBarButtonItems = [postButton]
        
    }
    
    // MARK: - Data Source
    func initDataSource() {
        dataSource = .init(tableView: display.tableview)
        
        dataSource.headerView = display.tableview.tableHeaderView as? StretchyTableHeaderView
        
        dataSource.tableUpdate(with: [GroupItems.name(viewModel.currentGroup), GroupItems.info(viewModel.currentGroup.leader)])
        
        dataSource.postSelected
            .sink { [weak self] in self?.coordinator?.goToCommentSection(with: $0)}
            .store(in: &subscriptions)
        
        dataSource.leaderSelected
            .sink { [weak self] in self?.coordinator?.showUser(user: $0)}
            .store(in: &subscriptions)
        
        dataSource.infoCellActionPublisher
            .sink { [weak self] in self?.infoCellAction($0)}
            .store(in: &subscriptions)
        
        dataSource.workoutTapped
            .sink { [weak self] in self?.viewModel.getWorkout(from: $0)}
            .store(in: &subscriptions)
        
        dataSource.userTapped
            .sink {[weak self] in self?.viewModel.getUser(from: $0)}
            .store(in: &subscriptions)
        
        dataSource.likeButtonTapped
            .sink { [weak self] in self?.viewModel.groupLikeCheck($0) }
            .store(in: &subscriptions)
        
        dataSource.scrolledToHeaderInView
            .sink { [weak self] in self?.initNavBarProfileImage($0)}
            .store(in: &subscriptions)
    }
    
    // MARK: - View Model
    func initViewModel() {
        
        viewModel.postsPublisher
            .sink { [weak self] in self?.dataSource.tableUpdatePosts(with: $0)}
            .store(in: &subscriptions)
        
        viewModel.leaderPublisher
            .dropFirst()
            .sink { [weak self] in self?.dataSource.updateLeader($0)}
            .store(in: &subscriptions)
        
        viewModel.headerImagePublisher
            .sink { [weak self] in self?.display.headerView.imageView.image = $0}
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
        
        viewModel.newPostListner
            .compactMap { $0 as? GroupPost }
            .sink { [weak self] in self?.dataSource.addNewPost($0)}
            .store(in: &subscriptions)
        
        viewModel.updatedGroupListener
            .sink { [weak self] (group, image) in
                self?.dataSource.updateName(group)
                if let image = image {
                    self?.display.headerView.imageView.image = image
                }
                self?.viewModel.currentGroup = group
            }
            .store(in: &subscriptions)
        
        viewModel.loadPosts()
        viewModel.loadHeaderImage()
        viewModel.loadGroupLeader()
    }
    
    // MARK: - Actions
    func initNavBarProfileImage(_ showingHeader: Bool) {
        if !showingHeader && !viewModel.showingNavBarImage {
            DispatchQueue.main.async {
                self.display.navBarView.image = self.viewModel.headerImagePublisher.value
                self.display.barView.addSubview(self.display.navBarView)
                self.navigationItem.titleView = self.display.barView
                UIView.animate(withDuration: 0.3) {
                    self.display.navBarView.alpha = 1.0
                }
            }
            viewModel.showingNavBarImage = true
        } else if showingHeader {
            DispatchQueue.main.async {
                self.navigationItem.title = nil
                self.navigationItem.titleView = nil
                self.display.navBarView.alpha = 0.0
            }
            viewModel.showingNavBarImage = false
        }
    }
    
    func infoCellAction(_ action: GroupInfoCellAction) {
        switch action {
        case .members:
            coordinator?.showMembers(viewModel.currentGroup)
        case .workouts:
            coordinator?.goToGroupWorkouts(with: viewModel.currentGroup)
        case .manage:
            coordinator?.showMoreInfo(with: viewModel.currentGroup, listener: viewModel.updatedGroupListener)
        }
    }

    @objc func postButtonTapped() {
        coordinator?.createNewPost(GroupPost(groupID: viewModel.currentGroup.uid), listener: viewModel.newPostListner)
    }
}


struct groupName: Hashable {
    var name: String
    var id: String = UUID().uuidString
    
    static func == (lhs: groupName, rhs: groupName) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct groupInfo: Hashable {
    var id: String = UUID().uuidString
    
    static func == (lhs: groupInfo, rhs: groupInfo) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct groupEmptyPosts: Hashable {
    var message: String = "No Posts in this group."
}


