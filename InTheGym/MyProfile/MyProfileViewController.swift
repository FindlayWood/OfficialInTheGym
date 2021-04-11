//
//  MyProfileViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 31/03/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class MyProfileViewController: UIViewController {
    
    @IBOutlet weak var tableview:UITableView!
    @IBOutlet weak var activityIndicator:UIActivityIndicatorView!
    @IBOutlet weak var followStackView:UIStackView!
    @IBOutlet weak var topActivityIndicator:UIActivityIndicatorView!
    
    @IBOutlet weak var profileImage:UIImageView!
    @IBOutlet weak var profileBio:UITextView!
    @IBOutlet weak var name:UILabel!
    @IBOutlet weak var username:UILabel!
    @IBOutlet weak var followingCount:UIButton!
    @IBOutlet weak var followerCount:UIButton!
    @IBOutlet weak var accountType:UIButton!
    @IBOutlet weak var accountTypeLabel:UILabel!
    
    var adapter : MyProfileAdapter!
    
    lazy var viewModel : MyProfileViewModel = {
        return MyProfileViewModel()
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        adapter = MyProfileAdapter(delegate: self)
        tableview.delegate = adapter
        tableview.dataSource = adapter
        tableview.rowHeight = UITableView.automaticDimension
        tableview.estimatedRowHeight = 90
        tableview.register(UINib(nibName: "TimelinePostTableViewCell", bundle: nil), forCellReuseIdentifier: "TimelinePostTableViewCell")
        tableview.register(UINib(nibName: "TimelineCreatedWorkoutTableViewCell", bundle: nil), forCellReuseIdentifier: "TimelineCreatedWorkoutTableViewCell")
        tableview.register(UINib(nibName: "TimelineCompletedWorkoutTableViewCell", bundle: nil), forCellReuseIdentifier: "TimelineCompletedTableViewCell")
        tableview.register(UINib(nibName: "TimelineActivityTableViewCell", bundle: nil), forCellReuseIdentifier: "TimelineActivityTableViewCell")
        tableview.register(UINib(nibName: "MyProfileCollectionTableViewCell", bundle: nil), forCellReuseIdentifier: "MyProfileCollectionTableViewCell")
        tableview.tableFooterView = UIView()
        tableview.alpha = 0.0
        tableview.backgroundColor = Constants.darkColour
        
        initViewModel()
        initUI()
        topActivityIndicator.hidesWhenStopped = true
        self.profileImage.alpha = 0.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        let textAttributes = [NSAttributedString.Key.foregroundColor:Constants.lightColour]
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes
        self.navigationController?.navigationBar.tintColor = Constants.lightColour
    }
    
    func initUI(){
        self.username.text = ViewController.username!
        if ViewController.admin {
            self.accountTypeLabel.text = "Coach"
            self.accountType.setImage(UIImage(named: "coach_icon"), for: .normal)
        } else {
            self.accountTypeLabel.text = "Player"
            self.accountType.setImage(UIImage(named: "player_icon"), for: .normal)
        }
        self.profileImage.layer.cornerRadius = self.profileImage.bounds.width / 2
        viewModel.returnUser { (user) in
            self.name.text = user.firstName! + " " + user.lastName!
            self.profileBio.text = user.profileBio
            if let purl = user.profilePhotoURL {
                ImageAPIService.shared.getImage(with: purl) { (image) in
                    if image != nil {
                        self.profileImage.image = image
                        self.profileImage.alpha = 1.0
                    }
                }
            } else {
                self.profileImage.alpha = 1.0
            }
            
        }
    }
    
    func initViewModel(){
        
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
                    self?.topActivityIndicator.startAnimating()
                    UIView.animate(withDuration: 0.2) {
                        self?.followStackView.alpha = 0.0
                    }
                } else {
                    self?.topActivityIndicator.stopAnimating()
                    UIView.animate(withDuration: 0.2) {
                        self?.followStackView.alpha = 1.0
                    }
                }
            }
        }
        
        viewModel.followerCount()
        viewModel.fetchData()
    }
    
    @IBAction func editProfile(_ sender:UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let editPage = storyboard.instantiateViewController(withIdentifier: "EditProfileViewController") as! EditProfileViewController
        if self.profileImage.image != nil{
            editPage.theImage = self.profileImage.image
        }
        editPage.theText = self.profileBio.text
        editPage.modalTransitionStyle = .coverVertical
        editPage.modalPresentationStyle = .fullScreen
        self.navigationController?.present(editPage, animated: true, completion: nil)
    }
    
    @IBAction func showFollowers(_ sender:UIButton){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextVC = storyboard.instantiateViewController(withIdentifier: "FollowersDisplayViewController") as! FollowersDisplayViewController
        nextVC.followers = true
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    @IBAction func showFollowing(_ sender:UIButton){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextVC = storyboard.instantiateViewController(withIdentifier: "FollowersDisplayViewController") as! FollowersDisplayViewController
        nextVC.followers = false
        self.navigationController?.pushViewController(nextVC, animated: true)
    }

}

extension MyProfileViewController: MyProfileProtocol, TimelineTapProtocol {
    func getData(at: IndexPath) -> PostProtocol {
        return viewModel.getData(at: at)
    }
    
    func getCollectionData() -> [[String:AnyObject]] {
        return viewModel.collectionData
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
    
    func collectionItemSelected(at: IndexPath) {
        let StoryBoard = UIStoryboard(name: "Main", bundle: nil)
        switch at.item {
        case 0:
            let SVC = StoryBoard.instantiateViewController(withIdentifier: "MyGroupsViewController") as! MyGroupsViewController
            self.navigationController?.pushViewController(SVC, animated: true)
        case 1:
            if ViewController.admin {
                let SVC = StoryBoard.instantiateViewController(withIdentifier: "CoachScoresViewController") as! CoachScoresViewController
                self.navigationController?.pushViewController(SVC, animated: true)
            } else {
                let SVC = StoryBoard.instantiateViewController(withIdentifier: "MYSCORESViewController") as! MYSCORESViewController
                navigationController?.pushViewController(SVC, animated: true)
            }
        case 2:
            let SVC = StoryBoard.instantiateViewController(withIdentifier: "SavedWorkoutsViewController") as! SavedWorkoutsViewController
            navigationController?.pushViewController(SVC, animated: true)
        case 3:
            
            let SVC = StoryBoard.instantiateViewController(withIdentifier: "CreatedWorkoutsViewController") as! CreatedWorkoutsViewController
            navigationController?.pushViewController(SVC, animated: true)
        case 4:
            let SVC = StoryBoard.instantiateViewController(withIdentifier: "DisplayNotificationsViewController") as! DisplayNotificationsViewController
            navigationController?.pushViewController(SVC, animated: true)
        case 5:
            let editPage = StoryBoard.instantiateViewController(withIdentifier: "EditProfileViewController") as! EditProfileViewController
            if self.profileImage.image != nil{
                editPage.theImage = self.profileImage.image
            }
            editPage.theText = self.profileBio.text
            editPage.modalTransitionStyle = .coverVertical
            editPage.modalPresentationStyle = .fullScreen
            self.navigationController?.present(editPage, animated: true, completion: nil)
        case 6:
            if ViewController.admin {
                let SVC = StoryBoard.instantiateViewController(withIdentifier: "CoachInfoViewController") as! CoachInfoViewController
                navigationController?.pushViewController(SVC, animated: true)
            } else {
                let SVC = StoryBoard.instantiateViewController(withIdentifier: "NewInfoViewController") as! NewInfoViewController
                navigationController?.pushViewController(SVC, animated: true)
            }
        default:
            break
        }
    }
    
    func retreiveNumberOfItems() -> Int {
        return viewModel.numberOfItems
    }
    
    func retreiveNumberOfSections() -> Int {
        return 2
    }
    
    func returnFollowerCounts(followerCount: Int, FollowingCount: Int) {
        self.followerCount.setTitle(followerCount.description, for: .normal)
        self.followingCount.setTitle(FollowingCount.description, for: .normal)
        self.followerCount.isUserInteractionEnabled = true
        self.followingCount.isUserInteractionEnabled = true
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
        viewModel.likePost(on: post, with: index)
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
    
}
