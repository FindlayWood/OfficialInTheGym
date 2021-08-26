//
//  GroupHomePageViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 12/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class GroupHomePageViewController: UIViewController {
    
    weak var coordinator: GroupHomeCoordinator?
    
    var display = GroupHomePageView()

    var adapter: GroupHomePageAdapter!
    
    var apiService = FirebaseAPIGroupService.shared
    
    var currentGroup: groupModel!
    
    lazy var viewModel: GroupHomePageViewModel = {
        return GroupHomePageViewModel(apiService: apiService)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .darkColour
        setUpDisplay()
        addNavBarButton()
        initViewModel()
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        display.frame = CGRect(x: 0, y: view.safeAreaInsets.top, width: view.frame.width, height: view.frame.height - view.safeAreaInsets.top)
        view.addSubview(display)
    }
    
    func initViewModel() {
        viewModel.reloadPostsTableViewClosure = { [weak self] in
            guard let self = self else {return}
            DispatchQueue.main.async {
                let sections = IndexSet.init(integer: 1)
                self.display.tableview.reloadSections(sections, with: .none)
            }
        }
        
        viewModel.reloadMembersTableViewClosure = { [weak self] in
            guard let self = self else {return}
            DispatchQueue.main.async {
                let sections = IndexSet.init(integer: 0)
                self.display.tableview.reloadSections(sections, with: .none)
            }
        }
        viewModel.reloadHeaderImageClosure = { [weak self] in
            guard let self = self else {return}
            DispatchQueue.main.async {
                self.display.headerView.imageView.image = self.viewModel.headerImage
            }
        }
        viewModel.updateNavigationTitleImage = { [weak self] in
            guard let self = self else {return}
            let titleImageShowing = self.viewModel.headerImageInView
            if !titleImageShowing {
                DispatchQueue.main.async {
                    let barView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
                    barView.layer.cornerRadius = 15
                    barView.clipsToBounds = true
                    let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
                    imageView.contentMode = .scaleAspectFill
                    imageView.layer.cornerRadius = 15
                    imageView.clipsToBounds = true
                    imageView.layer.masksToBounds = false
                    imageView.image = self.viewModel.headerImage
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
        viewModel.groupLeaderLoadedClosure = { [weak self] in
            guard let self = self else {return}
            DispatchQueue.main.async {
                let indexPath = IndexPath(row: 1, section: 0)
                self.display.tableview.reloadRows(at: [indexPath], with: .none)
            }
            
        }
        
        viewModel.loadPosts(from: currentGroup.uid)
        viewModel.loadMembers(from: currentGroup.uid)
        viewModel.loadHeaderImage(from: currentGroup.uid)
        viewModel.loadGroupLeader(from: currentGroup.leader)
    }
    
    @objc func moreButtonTapped() {
        print("go to more")
        let info = MoreGroupInfoModel(leader: getGroupLeader(),
                                      headerImage: getGroupImage(),
                                      description: currentGroup.description,
                                      groupName: currentGroup.username,
                                      groupID: currentGroup.uid,
                                      leaderID: currentGroup.leader)
        coordinator?.showMoreInfo(with: info, self)
    }
}

// MARK: - Adapter and Display Setup
extension GroupHomePageViewController {
    func setUpDisplay() {
        adapter = .init(delegate: self)
        adapter.headerView = display.tableview.tableHeaderView as? StretchyTableHeaderView
        display.tableview.delegate = adapter
        display.tableview.dataSource = adapter
        display.tableview.backgroundColor = .darkColour
    }
}

// MARK: - Navigation Controller Setup
extension GroupHomePageViewController {
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        let textAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes
        self.navigationController?.navigationBar.tintColor = UIColor.white
    }
    func addNavBarButton() {
        let barImage = viewModel.getBarImage()
        let barButton = UIBarButtonItem(image: barImage, style: .plain, target: self, action: #selector(moreButtonTapped))
        navigationItem.rightBarButtonItem = barButton
    }
}

// MARK: - Protocol Conformation
extension GroupHomePageViewController: GroupHomePageProtocol {
    func getGroupInfo() -> groupModel {
        return currentGroup
    }
    
    func getPostData(at indexPath: IndexPath) -> PostProtocol {
        return viewModel.getPostData(at: indexPath)
    }
    
    func numberOfPosts() -> Int {
        return viewModel.numberOfPosts
    }
    
    func postSelected(at indexPath: IndexPath) {
        let post = viewModel.getPostData(at: indexPath)
        if post is TimelinePostModel || post is TimelineCreatedWorkoutModel || post is TimelineCompletedWorkoutModel{
            var discussionPost: PostProtocol!
            switch post {
            case is TimelinePostModel:
                discussionPost = DiscussionPost(model: post as! TimelinePostModel)
            case is TimelineCreatedWorkoutModel:
                discussionPost = DiscussionCreatedWorkout(model: post as! TimelineCreatedWorkoutModel)
            case is TimelineCompletedWorkoutModel:
                discussionPost = DiscussionCompletedWorkout(model: post as! TimelineCompletedWorkoutModel)
            default:
                break
            }
            coordinator?.showDiscussion(with: discussionPost, group: currentGroup)
        }
    }
    func getGroupImage() -> UIImage? {
        return viewModel.headerImage
    }
    func numberOfMembers() -> Int {
        return viewModel.numberOfMembers
    }
    func scrolledTo(headerInView: Bool) {
        viewModel.headerImageInView = headerInView
    }
    func postsLoaded() -> Bool {
        return viewModel.postsLoadedSuccessfully
    }
    func getGroupLeader() -> Users {
        return viewModel.groupLeader
    }
    func leaderLoaded() -> Bool {
        return viewModel.groupLeaderLoadedSuccessfully
    }
    func newInfoSaved(_ newInfo: MoreGroupInfoModel) {
        viewModel.headerImage = newInfo.headerImage
        currentGroup.username = newInfo.groupName
        currentGroup.description = newInfo.description
        display.tableview.reloadData()
    }
    func goToWorkouts() {
        coordinator?.goToGroupWorkouts(with: currentGroup)
    }
}

// MARK: - Timeline Protocol Conformation
extension GroupHomePageViewController: TimelineTapProtocol {
    func likeButtonTapped(on cell: UITableViewCell, sender: UIButton, label: UILabel) {
        let index = display.tableview.indexPath(for: cell)!
        let post = viewModel.getPostData(at: index)
        viewModel.likePost(from: currentGroup.uid, on: post)
        let likeCount = Int(label.text!)! + 1
        label.text = likeCount.description
        if #available(iOS 13.0, *) {
            UIView.transition(with: sender, duration: 0.3, options: .transitionCrossDissolve) {
                sender.setImage(UIImage(systemName: "star.fill"), for: .normal)
            } completion: { _ in
                sender.isUserInteractionEnabled = false
            }
        }
        let selection = UISelectionFeedbackGenerator()
        selection.prepare()
        selection.selectionChanged()
    }
    func userTapped(on cell: UITableViewCell) {
        let index = display.tableview.indexPath(for: cell)!
        let post = viewModel.getPostData(at: index)
        let posterID = post.posterID
        UserIDToUser.transform(userID: posterID!) { [weak self] (user) in
            guard let self = self else {return}
            // TODO: fix this!
            if user.username != ViewController.username {
                self.coordinator?.showUser(user: user)
            }
        }
    }
    func workoutTapped(on cell: UITableViewCell) {
        let index = display.tableview.indexPath(for: cell)!
        let post = viewModel.getPostData(at:index)
        var workoutData: discoverWorkout!
        switch post {
        case is TimelineCreatedWorkoutModel:
            let p = post as! TimelineCreatedWorkoutModel
            workoutData = p.createdWorkout
            coordinator?.showWorkouts(with: workoutData)
        case is TimelineCompletedWorkoutModel:
            let p = post as! TimelineCompletedWorkoutModel
            workoutData = p.createdWorkout
            coordinator?.showWorkouts(with: workoutData)
        default:
            break
        }
    }
}
