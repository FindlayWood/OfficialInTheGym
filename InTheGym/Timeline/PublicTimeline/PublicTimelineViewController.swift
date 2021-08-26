//
//  PublicTimelineViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 23/03/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit
import EmptyDataSet_Swift

class PublicTimelineViewController: UIViewController, Storyboarded {
    
    weak var coordinator: UserProfileCoordinator?

    @IBOutlet weak var tableview:UITableView!
    @IBOutlet weak var activityIndicator:UIActivityIndicatorView!
    @IBOutlet weak var topViewIndicator:UIActivityIndicatorView!
    
    @IBOutlet weak var profileImage:UIImageView!
    @IBOutlet weak var profileBio:UITextView!
    @IBOutlet weak var name:UILabel!
    @IBOutlet weak var followingCount:UIButton!
    @IBOutlet weak var followerCount:UIButton!
    @IBOutlet weak var accountType:UIButton!
    @IBOutlet weak var accountTypeLabel:UILabel!
    @IBOutlet weak var followButton:UIButton!
    
    @IBOutlet weak var followStackView:UIStackView!
    
    var refreshControl : UIRefreshControl!
    let selection = UISelectionFeedbackGenerator()
    
    var adapter : PublicTimelineAdapter!
    
    // the user to view
    var user : Users!
    
    lazy var viewModel: PublicTimelineViewModel = {
        return PublicTimelineViewModel(user: user)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        adapter = PublicTimelineAdapter(delegate: self)
        tableview.delegate = adapter
        tableview.dataSource = adapter
        tableview.rowHeight = UITableView.automaticDimension
        tableview.estimatedRowHeight = 90
        tableview.register(UINib(nibName: "TimelinePostTableViewCell", bundle: nil), forCellReuseIdentifier: "TimelinePostTableViewCell")
        tableview.register(UINib(nibName: "TimelineCreatedWorkoutTableViewCell", bundle: nil), forCellReuseIdentifier: "TimelineCreatedWorkoutTableViewCell")
        tableview.register(UINib(nibName: "TimelineCompletedWorkoutTableViewCell", bundle: nil), forCellReuseIdentifier: "TimelineCompletedTableViewCell")
        tableview.register(UINib(nibName: "TimelineActivityTableViewCell", bundle: nil), forCellReuseIdentifier: "TimelineActivityTableViewCell")
        tableview.tableFooterView = UIView()
        tableview.backgroundColor = Constants.darkColour
        tableview.emptyDataSetSource = adapter
        tableview.emptyDataSetDelegate = adapter
        tableview.separatorInset = .zero
        tableview.layoutMargins = .zero
        self.profileImage.alpha = 0.0
        
        initUI()
        initRefreshControl()

        self.topViewIndicator.hidesWhenStopped = true
        
        selection.prepare()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if isMovingToParent{
            initViewModel()
        }
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        let textAttributes = [NSAttributedString.Key.foregroundColor:Constants.lightColour]
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes
        self.navigationController?.navigationBar.tintColor = Constants.lightColour
    }
    override func viewDidDisappear(_ animated: Bool) {
        if isMovingFromParent{
            //viewModel.removeObservers()
        }
    }
    
    override func viewWillLayoutSubviews() {
        self.profileImage.layer.cornerRadius = self.profileImage.bounds.width / 2
    }
    
    func initUI(){
        self.navigationItem.title = user.username
        self.profileBio.text = user.profileBio
        self.name.text = user.firstName + " " + user.lastName
        self.accountType.isUserInteractionEnabled = true
        if user.admin == true{
            self.accountType.setImage(UIImage(named: "coach_icon"), for: .normal)
            self.accountTypeLabel.text = "Coach"
        }else{
            self.accountType.setImage(UIImage(named: "player_icon"), for: .normal)
            self.accountTypeLabel.text = "Player"
        }
        let userID = user.uid
        ImageAPIService.shared.getProfileImage(for: userID) { [weak self] image in
            guard let self = self else {return}
            if image != nil {
                self.profileImage.image = image
                self.profileImage.alpha = 1.0
            } else {
                self.profileImage.alpha = 1.0
            }
        }        
    }
    
    func initViewModel(){
        
        // assign viewmodel delegate to self
        viewModel.delegate = self
        
        // Setup for reloadTableViewClosure
        viewModel.reloadTableViewClosure = { [weak self] () in
            DispatchQueue.main.async {
                self?.tableview.reloadData()
                if self!.tableview.refreshControl!.isRefreshing{
                    self?.tableview.refreshControl?.endRefreshing()
                }
            }
        }
        
        // Setup for updateLoadingStatusClosure
        viewModel.updateLoadingStatusClosure = { [weak self] () in
            DispatchQueue.main.async {
                let isLoading = self?.viewModel.isLoading ?? false
                if isLoading {
                    if !self!.tableview.refreshControl!.isRefreshing{
                        self?.activityIndicator.startAnimating()
                        UIView.animate(withDuration: 0.2, animations: {
                            self?.tableview.alpha = 0.0
                        })
                    }
                } else {
                    self?.activityIndicator.stopAnimating()
                    UIView.animate(withDuration: 0.2, animations: {
                        self?.tableview.alpha = 1.0
                    })
                }
            }
        }
        
        viewModel.showTopViewClosure = { [weak self] () in
            DispatchQueue.main.async {
                //show top view
                let isTopLoading = self?.viewModel.isTopViewLoading ?? false
                if isTopLoading {
                    self?.topViewIndicator.startAnimating()
                    UIView.animate(withDuration: 0.2) {
                        self?.followStackView.alpha = 0.0
                    }
                } else {
                    self?.topViewIndicator.stopAnimating()
                    UIView.animate(withDuration: 0.2) {
                        self?.followStackView.alpha = 1.0
                    }
                }
            }
        }
        viewModel.followerCount()
        viewModel.isFollowing()
    }
    
    func initRefreshControl(){
        refreshControl = UIRefreshControl()
        refreshControl.tintColor = .white
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        self.tableview.refreshControl = refreshControl
    }
    
    @objc func handleRefresh(){
        viewModel.followerCount()
        viewModel.isFollowing()
    }
    
    
    // MARK: - Actions
    
    @IBAction func follow(_ sender:UIButton){
        sender.backgroundColor = .lightGray
        sender.setTitle("Following", for: .normal)
        sender.isUserInteractionEnabled = false
        selection.selectionChanged()
        viewModel.follow { [weak self] (result) in
            switch result{
            case .success(_):
                self?.viewModel.followerCount()
                self?.viewModel.isFollowing()
            case .failure(let error):
                print(error.localizedDescription)
                sender.isUserInteractionEnabled = true
                sender.backgroundColor = Constants.lightColour
                sender.setTitle("Follow", for: .normal)
                DisplayTopView.displayTopView(with: "Try Again", on: self!)
            }
        }
    }
    
    @IBAction func showCreatedWorkouts(_ sender:UIButton){
        coordinator?.showCreatedWorkouts(for: user)
//        let Storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let nextVC = Storyboard.instantiateViewController(withIdentifier: "PublicCreatedWorkoutsViewController") as! PublicCreatedWorkoutsViewController
//        nextVC.user = self.user
//        self.navigationController?.pushViewController(nextVC, animated: true)
//        coordinator?.showCreatedWorkouts(for: user)
    }

}

extension PublicTimelineViewController: PublicTimelineProtocol, TimelineTapProtocol{
    func getData(at: IndexPath) -> PostProtocol {
        return viewModel.getData(at: at)
    }
    
    func itemSelected(at: IndexPath) {
        let post = viewModel.getData(at: at)
        if post is TimelinePostModel || post is TimelineCreatedWorkoutModel || post is TimelineCompletedWorkoutModel{
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            let discussionVC = storyboard.instantiateViewController(withIdentifier: "DiscussionViewViewController") as! DiscussionViewViewController
//            discussionVC.hidesBottomBarWhenPushed = true
//            switch post {
//            case is TimelinePostModel:
//                discussionVC.originalPost = DiscussionPost(model: post as! TimelinePostModel)
//            case is TimelineCreatedWorkoutModel:
//                discussionVC.originalPost = DiscussionCreatedWorkout(model: post as! TimelineCreatedWorkoutModel)
//            case is TimelineCompletedWorkoutModel:
//                discussionVC.originalPost = DiscussionCompletedWorkout(model: post as! TimelineCompletedWorkoutModel)
//            default:
//                break
//            }
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
            coordinator?.showDiscussion(with: discussionPost, group: nil)
            
            //self.navigationController?.pushViewController(discussionVC, animated: true)
        }
    }
    
    func retreiveNumberOfItems() -> Int {
        return viewModel.numberOfItems
    }
    
    func retreiveNumberOfSections() -> Int {
        return 1
    }
    
    func returnFollowerCounts(followerCount: Int, FollowingCount: Int) {
        self.followerCount.setTitle(followerCount.description, for: .normal)
        self.followingCount.setTitle(FollowingCount.description, for: .normal)
        self.followerCount.isUserInteractionEnabled = false
        self.followingCount.isUserInteractionEnabled = false
    }
    
    func returnIsFollowing(following: Bool) {
        if following{
            self.followButton.setTitle("Following", for: .normal)
            self.followButton.backgroundColor = .lightGray
            self.followButton.isUserInteractionEnabled = false
        } else {
            self.followButton.setTitle("Follow", for: .normal)
            self.followButton.backgroundColor = Constants.lightColour
            self.followButton.isUserInteractionEnabled = true
        }
    }
    
    func workoutTapped(on cell: UITableViewCell) {
        let index = self.tableview.indexPath(for: cell)!
        let post = viewModel.getData(at:index)
        var workoutData : discoverWorkout!
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let displayWorkout = storyboard.instantiateViewController(withIdentifier: "DisplayWorkoutViewController") as! DisplayWorkoutViewController
        displayWorkout.hidesBottomBarWhenPushed = true
        switch post {
        case is TimelineCreatedWorkoutModel:
            let p = post as! TimelineCreatedWorkoutModel
            workoutData = p.createdWorkout
            coordinator?.showWorkout(workout: workoutData)
//            DisplayWorkoutViewController.selectedWorkout = workoutData
//            self.navigationController?.pushViewController(displayWorkout, animated: true)
        case is TimelineCompletedWorkoutModel:
            let p = post as! TimelineCompletedWorkoutModel
            workoutData = p.createdWorkout
            coordinator?.showWorkout(workout: workoutData)
//            DisplayWorkoutViewController.selectedWorkout = workoutData
//            self.navigationController?.pushViewController(displayWorkout, animated: true)
        default:
            break
        }
        
    
    }
    
    func likeButtonTapped(on cell: UITableViewCell, sender: UIButton, label: UILabel) {
        
        self.selection.selectionChanged()
        if #available(iOS 13.0, *) {
            UIView.transition(with: sender, duration: 0.3, options: .transitionCrossDissolve) {
                sender.setImage(UIImage(systemName: "star.fill"), for: .normal)
            } completion: { _ in
                sender.isUserInteractionEnabled = false
            }

        }
        
        let index = self.tableview.indexPath(for: cell)!
        let post = viewModel.getData(at: index)
        
        
        viewModel.isLiked(on: post.postID!) { (result) in
            switch result {
            
            case .success(let liked):
                if !liked {
                    // here is where we like the post
                    print("post is not liked - like it now")
                    self.viewModel.likePost(on: post, with: index)
                    let likeCount = Int(label.text!)! + 1
                    label.text = likeCount.description
                }
                
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func userTapped(on cell: UITableViewCell) {
        
    }
    
    func reloadTableviewRow(at: IndexPath) {
        self.tableview.reloadRows(at: [at], with: .none)
    }
    
    func newPosts() {
        self.tableview.beginUpdates()
        self.tableview.insertRows(at: [IndexPath(row: 0, section: 0)], with: .top)
        self.tableview.endUpdates()
    }
    
}
