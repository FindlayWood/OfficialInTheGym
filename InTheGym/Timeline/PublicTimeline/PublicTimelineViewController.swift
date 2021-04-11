//
//  PublicTimelineViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 23/03/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class PublicTimelineViewController: UIViewController {

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
        self.profileImage.alpha = 0.0
        
        initViewModel()
        initUI()

        self.topViewIndicator.hidesWhenStopped = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        let textAttributes = [NSAttributedString.Key.foregroundColor:Constants.lightColour]
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes
        self.navigationController?.navigationBar.tintColor = Constants.lightColour
    }
    
    func initUI(){
        self.navigationItem.title = user.username!
        self.profileBio.text = user.profileBio
        self.name.text = user.firstName! + " " + user.lastName!
        self.accountType.isUserInteractionEnabled = false
        if user.admin == true{
            self.accountType.setImage(UIImage(named: "coach_icon"), for: .normal)
            self.accountTypeLabel.text = "Coach"
        }else{
            self.accountType.setImage(UIImage(named: "player_icon"), for: .normal)
            self.accountTypeLabel.text = "Player"
        }
        self.profileImage.layer.cornerRadius = self.profileImage.bounds.width / 2
        if let purl = user.profilePhotoURL{
            ImageAPIService.shared.getImage(with: purl) { (image) in
                if image != nil {
                    self.profileImage.image = image
                    self.profileImage.alpha = 1.0
                } else {
                    self.profileImage.alpha = 1.0
                }
            }
        } else {
            self.profileImage.alpha = 1.0
        }
        
    }
    
    func initViewModel(){
        
        // assign viewmodel delegate to self
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
    
    @IBAction func follow(_ sender:UIButton){
        viewModel.follow()
    }

}

extension PublicTimelineViewController: PublicTimelineProtocol, TimelineTapProtocol{
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
        }
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
        viewModel.likePost(on: post)
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
