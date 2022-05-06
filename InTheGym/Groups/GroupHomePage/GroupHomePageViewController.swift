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
    
//    private lazy var dataSource = makeDataSorce()
    
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .darkColour
        initDisplay()
        addNavBarButton()
        initDataSource()
        initViewModel()

    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        display.frame = getFullViewableFrame()
        view.addSubview(display)
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
        //let barImage = viewModel.getBarImage()
        //let barButton = UIBarButtonItem(image: barImage, style: .plain, target: self, action: #selector(moreButtonTapped))
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
                self?.display.headerView.imageView.image = image
                self?.viewModel.currentGroup = group
            }
            .store(in: &subscriptions)
        
        viewModel.loadPosts()
        viewModel.loadHeaderImage()
        viewModel.loadGroupLeader()
    }
    
    // MARK: - Actions
    func initNavBarProfileImage(_ showingHeader: Bool) {
        if !showingHeader {
            DispatchQueue.main.async {
                let barView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
                barView.layer.cornerRadius = 15
                barView.clipsToBounds = true
                let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
                imageView.contentMode = .scaleAspectFill
                imageView.layer.cornerRadius = 15
                imageView.clipsToBounds = true
                imageView.layer.masksToBounds = false
                imageView.image = self.viewModel.headerImagePublisher.value
                imageView.alpha = 0.0
                barView.addSubview(imageView)
                self.navigationItem.titleView = barView
                UIView.animate(withDuration: 0.5) {
                    imageView.alpha = 1.0
                }
            }
        } else {
            DispatchQueue.main.async {
                self.navigationItem.title = nil
                self.navigationItem.titleView = nil
            }
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
    
    @objc func moreButtonTapped() {
//        let info = MoreGroupInfoModel(leader: getGroupLeader(),
//                                      headerImage: getGroupImage(),
//                                      description: currentGroup.description,
//                                      groupName: currentGroup.username,
//                                      groupID: currentGroup.uid,
//                                      leaderID: currentGroup.leader)
//        coordinator?.showMoreInfo(with: info, self)
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


