//
//  PlayerTimelineViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 15/03/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class PlayerTimelineViewController: UIViewController, UITabBarControllerDelegate {
    
    @IBOutlet weak var tableview:UITableView!
    @IBOutlet weak var activityIndicator:UIActivityIndicatorView!
    
    var newPostsButton:SeeNewPostsButton!
    var newPostsButtonTopAnchor:NSLayoutConstraint!
    
    var refreshControl:UIRefreshControl!
    
    var adapter : PlayerTimelineAdapter!
    
    lazy var viewModel: PlayerTimelineViewModel = {
        return PlayerTimelineViewModel()
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        adapter = PlayerTimelineAdapter(delegate: self)
        tableview.delegate = adapter
        tableview.dataSource = adapter
        tableview.rowHeight = UITableView.automaticDimension
        tableview.estimatedRowHeight = 90
        tableview.backgroundColor = Constants.darkColour
        tableview.register(UINib(nibName: "TimelinePostTableViewCell", bundle: nil), forCellReuseIdentifier: "TimelinePostTableViewCell")
        tableview.register(UINib(nibName: "TimelineCreatedWorkoutTableViewCell", bundle: nil), forCellReuseIdentifier: "TimelineCreatedWorkoutTableViewCell")
        tableview.register(UINib(nibName: "TimelineCompletedWorkoutTableViewCell", bundle: nil), forCellReuseIdentifier: "TimelineCompletedTableViewCell")
        tableview.register(UINib(nibName: "TimelineActivityTableViewCell", bundle: nil), forCellReuseIdentifier: "TimelineActivityTableViewCell")
        tableview.tableFooterView = UIView()
        tableview.separatorInset = .zero
        tableview.layoutMargins = .zero
        
        self.tabBarController?.delegate = self
        
        initViewModel()
        initNewPostButton()
        initRefreshControl()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func initViewModel(){
        
        //assign self as viewmodel delegate
        viewModel.delegate = self
        
        // Setup for reloadTableViewClosure
        viewModel.reloadTableViewClosure = { [weak self] () in
            DispatchQueue.main.async {
                self?.tableview.reloadData()
            }
        }
        
        // Setup for updateLoadingStatusClosure
        viewModel.updateLoadingStatusClosure = { [weak self] () in
            DispatchQueue.main.async {
                let isLoading = self?.viewModel.isLoading ?? false
                if isLoading {
                    self?.activityIndicator.startAnimating()
                    UIView.animate(withDuration: 0.2, animations: {
                        self?.tableview.alpha = 0.0
                    })
                    
                } else {
                    self?.activityIndicator.stopAnimating()
                    UIView.animate(withDuration: 0.2, animations: {
                        self?.tableview.alpha = 1.0
                    })
                }
            }
        }
        
        viewModel.newPostsLoadedClosure = { [weak self] () in
            self?.toggleNewPostsButton(hidden: false)
        }
        
        viewModel.tableViewReloadedClosure = { [weak self] () in
            let isRefreshing = self?.viewModel.isRefreshing ?? false
            if !isRefreshing {
                self?.tableview.reloadData()
                self?.refreshControl.endRefreshing()
                self?.tableview.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            }
        }
        
        viewModel.fetchData()
    }
    
    func initNewPostButton(){
        newPostsButton = SeeNewPostsButton()
        view.addSubview(newPostsButton)
        newPostsButton.translatesAutoresizingMaskIntoConstraints = false
        newPostsButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        newPostsButtonTopAnchor = newPostsButton.topAnchor.constraint(equalTo: self.tableview.topAnchor, constant: 12)
        newPostsButtonTopAnchor.isActive = true
        newPostsButton.heightAnchor.constraint(equalToConstant: 32).isActive = true
        newPostsButton.widthAnchor.constraint(equalToConstant: newPostsButton.button.bounds.width).isActive = true
        newPostsButton.button.addTarget(self, action: #selector(newPostsPressed(_:)), for: .touchUpInside)
        newPostsButton.isHidden = true
        
        
    }
    
    func initRefreshControl(){
        refreshControl = UIRefreshControl()
        refreshControl.tintColor = .white
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        self.tableview.refreshControl = refreshControl
    }
    
    @objc func handleRefresh(){
        // go to viewmodel to refresh
        viewModel.fetchData()
    }
    
    @objc func newPostsPressed(_ sender:UIButton){
        toggleNewPostsButton(hidden: true)
        viewModel.fetchData()
    }
    
    func toggleNewPostsButton(hidden:Bool){
        if hidden {
            self.newPostsButton.isHidden = true
        } else {
            self.newPostsButton.isHidden = false
            UIView.animate(withDuration: 0.5, delay: 1.0, options: .curveEaseOut, animations: {
                self.newPostsButtonTopAnchor.constant = 12
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
    @IBAction func makePostPressed(_ sender:UIButton){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let postVC = storyboard.instantiateViewController(withIdentifier: "MakePostViewController") as! MakePostViewController
        if ViewController.admin {
            postVC.playerPost = false
        } else {
            postVC.playerPost = true
        }
        postVC.groupBool = false
        postVC.timelineDelegate = self
        postVC.modalTransitionStyle = .coverVertical
        postVC.modalPresentationStyle = .fullScreen
        self.navigationController?.present(postVC, animated: true, completion: nil)
        
    }
    
    // tap tab bar to scroll to top
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if tabBarController.selectedViewController === viewController {
            self.tableview.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
        return true
    }
    

}
extension PlayerTimelineViewController: PlayerTimelineProtocol, TimelineTapProtocol{
    func getData(at: IndexPath) -> PostProtocol {
        return viewModel.getData(at: at)
    }
    
    func itemSelected(at: IndexPath) {
        let post = viewModel.getData(at: at)
        if post is TimelinePostModel || post is TimelineCreatedWorkoutModel || post is TimelineCompletedWorkoutModel{
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let discussionVC = storyboard.instantiateViewController(withIdentifier: "DiscussionViewViewController") as! DiscussionViewViewController
            switch post {
            case is TimelinePostModel:
                discussionVC.originalPost = DiscussionPost(model: post as! TimelinePostModel)
            case is TimelineCreatedWorkoutModel:
                discussionVC.originalPost = DiscussionCreatedWorkout(model: post as! TimelineCreatedWorkoutModel)
            case is TimelineCompletedWorkoutModel:
                discussionVC.originalPost = DiscussionCompletedWorkout(model: post as! TimelineCompletedWorkoutModel)
            default:
                break
            }
            
            self.navigationController?.pushViewController(discussionVC, animated: true)
        }
    }
    
    func retreiveNumberOfItems() -> Int {
        return viewModel.numberOfItems
    }
    
    func retreiveNumberOfSections() -> Int {
        return 1
    }
    
    func newPosts() {
        self.tableview.beginUpdates()
        self.tableview.insertRows(at: [IndexPath(row: 0, section: 0)], with: .top)
        self.tableview.endUpdates()
    }
    
    func postFromSelf(post: TimelinePostModel) {
        self.viewModel.fetchData()
    }
    
    func workoutTapped(on cell: UITableViewCell) {
        let index = self.tableview.indexPath(for: cell)!
        let post = viewModel.getData(at:index)
        var workoutData : discoverWorkout!
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let displayWorkout = storyboard.instantiateViewController(withIdentifier: "DisplayWorkoutViewController") as! DisplayWorkoutViewController
        switch post {
        case is TimelineCreatedWorkoutModel:
            let p = post as! TimelineCreatedWorkoutModel
            workoutData = p.createdWorkout
            displayWorkout.selectedWorkout = workoutData
            self.navigationController?.pushViewController(displayWorkout, animated: true)
        case is TimelineCompletedWorkoutModel:
            let p = post as! TimelineCompletedWorkoutModel
            workoutData = p.createdWorkout
            displayWorkout.selectedWorkout = workoutData
            self.navigationController?.pushViewController(displayWorkout, animated: true)
        default:
            break
        }
        
    
    }
    
    func likeButtonTapped(on cell: UITableViewCell, sender: UIButton, label: UILabel) {
        
        let index = self.tableview.indexPath(for: cell)!
        let post = viewModel.getData(at: index)
        
        
        viewModel.isLiked(on: post.postID!) { (result) in
            switch result {
            
            case .success(let liked):
                if !liked {
                    // here is where we like the post
                    self.viewModel.likePost(on: post, with: index)
                    let likeCount = Int(label.text!)! + 1
                    label.text = likeCount.description
                    if #available(iOS 13.0, *) {
                        UIView.transition(with: sender, duration: 0.3, options: .transitionCrossDissolve) {
                            sender.setImage(UIImage(systemName: "star.fill"), for: .normal)
                        }
                    } else {
                        // Fallback on earlier versions
                        print("needs fixing")
                    }
                    let selection = UISelectionFeedbackGenerator()
                    selection.prepare()
                    selection.selectionChanged()
                }
                
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        
        

    }
    
    func userTapped(on cell: UITableViewCell) {
        let index = self.tableview.indexPath(for: cell)!
        let post = viewModel.getData(at: index)
        if post.posterID == viewModel.userID {
            if ViewController.admin{
                self.tabBarController?.selectedIndex = 3
            } else {
                self.tabBarController?.selectedIndex = 3
            }
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let publicTimeline = storyboard.instantiateViewController(withIdentifier: "PublicTimelineViewController") as! PublicTimelineViewController
            let posterID = post.posterID
            UserIDToUser.transform(userID: posterID!) { (user) in
                publicTimeline.user = user
                self.navigationController?.pushViewController(publicTimeline, animated: true)
            }
        }
    }
    
}
