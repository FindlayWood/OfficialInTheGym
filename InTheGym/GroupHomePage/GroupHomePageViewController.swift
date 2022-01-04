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
    
    var currentGroup: groupModel!
    
    private lazy var groupPostsModel = GroupPostsModel(groupID: currentGroup.uid)
    
    lazy var viewModel: GroupHomePageViewModel = {
        return GroupHomePageViewModel()
    }()
    
    private lazy var dataSource = makeDataSorce()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .darkColour
        setUpDisplay()
        addNavBarButton()
        initViewModel()
        initTableView()
        if currentGroup.leader == FirebaseAuthManager.currentlyLoggedInUser.uid {
            
        }
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
                self.tableUpdatePosts(with: self.viewModel.posts)
                //let sections = IndexSet.init(integer: 1)
                //self.display.tableview.reloadSections(sections, with: .none)
            }
        }
        
        viewModel.reloadMembersTableViewClosure = { [weak self] in
            guard let self = self else {return}
            DispatchQueue.main.async {
                //let sections = IndexSet.init(integer: 0)
                //self.display.tableview.reloadSections(sections, with: .none)
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
                self.tableUpdate(with: [.leader(self.getGroupLeader())])
                //let indexPath = IndexPath(row: 1, section: 0)
                //let sections = IndexSet.init(integer: 0)
                //self.display.tableview.reloadRows(at: [indexPath], with: .none)
                //self.display.tableview.reloadSections(sections, with: .none)
            }
            
        }
        
        viewModel.tappedUserReturnedClosure = { [weak self] (tappedUser) in
            guard let self = self else {return}
            self.coordinator?.showUser(user: tappedUser)
        }
        
        viewModel.tappedWorkoutClosure = { [weak self] tappedWorkout in
            guard let self = self else {return}
            self.coordinator?.showWorkouts(with: tappedWorkout)
        }
        
        viewModel.currentGroup = currentGroup
        //viewModel.loadPosts(from: currentGroup.uid)
        viewModel.newLoadPosts(from: groupPostsModel)
        viewModel.loadMembers(from: currentGroup.uid)
        viewModel.loadHeaderImage(from: currentGroup.uid)
        viewModel.loadGroupLeader(from: currentGroup.leader)
    }
    
    func initTableView() {
        tableSetup()
        let currentItems: [GroupItems] = [.name(currentGroup)]
        tableUpdate(with: currentItems)
        let infoItems: [GroupItems] = [.info(groupInfo())]
        tableUpdate(with: infoItems)
    }
    
    @objc func moreButtonTapped() {
        let info = MoreGroupInfoModel(leader: getGroupLeader(),
                                      headerImage: getGroupImage(),
                                      description: currentGroup.description,
                                      groupName: currentGroup.username,
                                      groupID: currentGroup.uid,
                                      leaderID: currentGroup.leader)
        coordinator?.showMoreInfo(with: info, self)
    }
    @objc func postButtonTapped() {
        coordinator?.createNewPost()
    }
}

// MARK: - Adapter and Display Setup
extension GroupHomePageViewController {
    func setUpDisplay() {
        adapter = .init(delegate: self)
        adapter.headerView = display.tableview.tableHeaderView as? StretchyTableHeaderView
        display.tableview.delegate = adapter
        display.tableview.dataSource = makeDataSorce()
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
        //let barImage = viewModel.getBarImage()
        //let barButton = UIBarButtonItem(image: barImage, style: .plain, target: self, action: #selector(moreButtonTapped))
        if #available(iOS 13.0, *) {
            let postButton = UIBarButtonItem(image: UIImage(systemName: "pencil.circle.fill"), style: .plain, target: self, action: #selector(postButtonTapped))
            navigationItem.rightBarButtonItems = [postButton]
        }
        
    }
}

// MARK: - Protocol Conformation
extension GroupHomePageViewController: GroupHomePageProtocol {
    func getGroupInfo() -> groupModel {
        return currentGroup
    }
    
    func getPostData(at indexPath: IndexPath) -> GroupPost {
        return viewModel.getPostData(at: indexPath)
    }
    
    func numberOfPosts() -> Int {
        return viewModel.numberOfPosts
    }
    
    func postSelected(at indexPath: IndexPath) {
        let post = viewModel.getPostData(at: indexPath)
        coordinator?.goToCommentSection(with: post)
//        if post is TimelinePostModel || post is TimelineCreatedWorkoutModel || post is TimelineCompletedWorkoutModel{
//            var discussionPost: PostProtocol!
//            switch post {
//            case is TimelinePostModel:
//                discussionPost = DiscussionPost(model: post as! TimelinePostModel)
//            case is TimelineCreatedWorkoutModel:
//                discussionPost = DiscussionCreatedWorkout(model: post as! TimelineCreatedWorkoutModel)
//            case is TimelineCompletedWorkoutModel:
//                discussionPost = DiscussionCompletedWorkout(model: post as! TimelineCompletedWorkoutModel)
//            default:
//                break
//            }
//            coordinator?.showDiscussion(with: discussionPost, group: currentGroup)
//        }
    }
    func leaderSelected() {
        self.coordinator?.showUser(user: viewModel.groupLeader)
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
    func showGroupMembers() {
        
    }
    func isCurrentUserLeader() -> Bool {
        return viewModel.isCurrentUserLeader()
    }
    func manageGroup() {
        moreButtonTapped()
    }
}

// MARK: - Timeline Protocol Conformation
extension GroupHomePageViewController: TimelineTapProtocol {
    func likeButtonTapped(on cell: UITableViewCell, sender: UIButton, label: UILabel) {
        guard let index = display.tableview.indexPath(for: cell) else {return}
        guard let cell = cell as? PostTableViewCell else {return}
        cell.postLikedTransition()
        viewModel.likePost(at: index)
//        let post = viewModel.getPostData(at: index)
//        viewModel.likePost(from: currentGroup.uid, on: post)
//        let likeCount = Int(label.text!)! + 1
//        label.text = likeCount.description
//        if #available(iOS 13.0, *) {
//            UIView.transition(with: sender, duration: 0.3, options: .transitionCrossDissolve) {
//                sender.setImage(UIImage(systemName: "star.fill"), for: .normal)
//            } completion: { _ in
//                sender.isUserInteractionEnabled = false
//            }
//        }
//        let selection = UISelectionFeedbackGenerator()
//        selection.prepare()
//        selection.selectionChanged()
    }
    func userTapped(on cell: UITableViewCell) {
        guard let index = display.tableview.indexPath(for: cell) else {return}
        viewModel.userTapped(at: index)
    }
    func workoutTapped(on cell: UITableViewCell) {
        guard let index = display.tableview.indexPath(for: cell) else {return}
        viewModel.workoutTapped(at: index)
    }
}

extension GroupHomePageViewController {
    
    enum GroupSections {
        case groupName
        case groupLeader
        case groupInfo
        case groupPosts
    }
    

    
    func makeDataSorce() -> UITableViewDiffableDataSource<GroupSections,GroupItems> {
        return UITableViewDiffableDataSource(tableView: display.tableview) { tableView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .name(let model):
                let cell = UITableViewCell()
                cell.textLabel?.text = model.username
                cell.textLabel?.font = Constants.font
                cell.selectionStyle = .none
                return cell
            case .leader(let leader):
                let cell = tableView.dequeueReusableCell(withIdentifier: UserTableViewCell.cellID, for: indexPath) as! UserTableViewCell
                cell.configureCell(with: leader)
                return cell
            case .info(_):
                let cell = tableView.dequeueReusableCell(withIdentifier: GroupHomePageInfoTableViewCell.cellID, for: indexPath) as! GroupHomePageInfoTableViewCell
                cell.configureForLeader(self.currentGroup.leader == FirebaseAuthManager.currentlyLoggedInUser.uid)
                cell.delegate = self
                return cell
            case .posts(let model):
                let cell = tableView.dequeueReusableCell(withIdentifier: PostTableViewCell.cellID, for: indexPath) as! PostTableViewCell
                cell.configure(with: model)
                cell.delegate = self
                return cell
            }
        }
    }
    
    func tableSetup() {
        var currentSnapshot = dataSource.snapshot()
        currentSnapshot.appendSections([.groupName, .groupLeader, .groupInfo, .groupPosts])
        dataSource.apply(currentSnapshot, animatingDifferences: true)
    }
    func tableUpdate(with items: [GroupItems]) {
        var currentSnapshot = dataSource.snapshot()
        for item in items {
            switch item {
            case .name(let groupModel):
                currentSnapshot.appendItems([.name(groupModel)], toSection: .groupName)
            case .leader(let users):
                currentSnapshot.appendItems([.leader(users)], toSection: .groupLeader)
            case .info(let groupInfo):
                currentSnapshot.appendItems([.info(groupInfo)], toSection: .groupInfo)
            case .posts(let post):
                currentSnapshot.appendItems([.posts(post)], toSection: .groupPosts)
            }
        }
        dataSource.apply(currentSnapshot, animatingDifferences: true)
    }
    func tableUpdatePosts(with posts: [GroupPost]) {
        var currentSnapshot = dataSource.snapshot()
        for post in posts {
            currentSnapshot.appendItems([.posts(post)], toSection: .groupPosts)
        }
        dataSource.apply(currentSnapshot, animatingDifferences: true)
    }
//
//    func updateGroupName(with name: groupName) {
//        var currentSnapshot = dataSource.snapshot()
//
//        currentSnapshot.appendSections([.groupName])
//
//        currentSnapshot.appendItems([name], toSection: .groupName)
//        dataSource.apply(currentSnapshot, animatingDifferences: true)
//    }
//
//    func updateGroupLeader(with leader: Users) {
//        var currentSnapshot = dataSource.snapshot()
//
//        currentSnapshot.appendSections([.groupLeader])
//        currentSnapshot.appendItems([leader], toSection: .groupLeader)
//
//        dataSource.apply(currentSnapshot, animatingDifferences: true)
//    }
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

enum GroupItems: Hashable {
    case name(groupModel)
    case leader(Users)
    case info(groupInfo)
    case posts(GroupPost)
}
