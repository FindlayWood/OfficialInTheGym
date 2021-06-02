//
//  MyProfileViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 31/03/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit
import SCLAlertView

class MyProfileViewController: UIViewController, Storyboarded {
    
    var coordinator: MyProfileFlow?
    
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
    
    var refreshControl : UIRefreshControl!
    
    var adapter : MyProfileAdapter!
    
    lazy var viewModel : MyProfileViewModel = {
        return MyProfileViewModel()
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        showFirstMessage()

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
        tableview.separatorInset = .zero
        tableview.layoutMargins = .zero
        
        
        checkForNotifications()
        initViewModel()
        initUI()
        initRefreshControl()
        topActivityIndicator.hidesWhenStopped = true
        self.profileImage.alpha = 0.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        let textAttributes = [NSAttributedString.Key.foregroundColor:Constants.lightColour]
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes
        self.navigationController?.navigationBar.tintColor = Constants.lightColour
    }
    
    override func viewWillLayoutSubviews() {
        self.profileImage.layer.cornerRadius = self.profileImage.bounds.width / 2
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

        viewModel.returnUser { (user) in
            self.name.text = user.firstName! + " " + user.lastName!
            self.profileBio.text = user.profileBio
            ImageAPIService.shared.getProfileImage(for: user.uid!) { (image) in
                if let image = image {
                    self.profileImage.image = image
                    self.profileImage.alpha = 1.0
                } else {
                    self.profileImage.alpha = 1.0
                    let ystart = self.profileImage.frame.minY
                    let alert = ProfilePhotoAlert(frame: CGRect(x: 5, y: ystart, width: UIScreen.main.bounds.width - 10, height: 60))
                    self.view.addSubview(alert)
                    alert.editProfile = { [weak self] () in
                        guard let self = self else {return}
                        self.coordinator?.editProfile(profileImage: nil, profileBIO: self.profileBio.text, delegate: self)
                    }
                }
            }
        }
    }
    
    func initViewModel(){
        
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
                    self?.activityIndicator.startAnimating()
                    if !self!.tableview.refreshControl!.isRefreshing{
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
        //viewModel.fetchData()
        viewModel.loading()
    }
    
    func initRefreshControl(){
        refreshControl = UIRefreshControl()
        refreshControl.tintColor = .white
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        self.tableview.refreshControl = refreshControl
    }
    
    @objc func handleRefresh(){
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
        editPage.delegate = self
        editPage.modalTransitionStyle = .coverVertical
        editPage.modalPresentationStyle = .fullScreen
        self.navigationController?.present(editPage, animated: true, completion: nil)
    }
    
    @IBAction func showFollowers(_ sender:UIButton){
        coordinator?.showFollowers(true)
    }
    
    @IBAction func showFollowing(_ sender:UIButton){
        coordinator?.showFollowers(false)
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
            //let storyboard = UIStoryboard(name: "Main", bundle: nil)
            //let discussionVC = storyboard.instantiateViewController(withIdentifier: "DiscussionViewViewController") as! DiscussionViewViewController
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
            
            self.coordinator?.showDiscussion(with: discussionPost, isGroup: false)
            
            //self.navigationController?.pushViewController(discussionVC, animated: true)
        }
    }
    
    func collectionItemSelected(at: IndexPath) {
        switch at.item {
        case 0:
            coordinator?.showGroups()
        case 1:
            coordinator?.showNotifications()
        case 2:
            coordinator?.showSavedWorkouts()
        case 3:
            coordinator?.showCreatedWorkouts()
        case 4:
            coordinator?.showScores()
        case 5:
            coordinator?.editProfile(profileImage: profileImage.image, profileBIO: profileBio.text, delegate: self)
        case 6:
            coordinator?.showMoreInfo()
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
    
    func changedProfilePhoto(to newImage:UIImage) {
        self.profileImage.image = newImage
        viewModel.fetchData()
    }
    func changedBio(to newBio: String) {
        self.profileBio.text = newBio
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
            DisplayWorkoutViewController.selectedWorkout = workoutData
            self.navigationController?.pushViewController(displayWorkout, animated: true)
        case is TimelineCompletedWorkoutModel:
            let p = post as! TimelineCompletedWorkoutModel
            workoutData = p.createdWorkout
            DisplayWorkoutViewController.selectedWorkout = workoutData
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
                    print("post is not liked - like it now")
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
        
    }
    
}

// extension for first time message
extension MyProfileViewController {
    func showFirstMessage() {
        if UIApplication.isFirstProfileLaunch() {

            let screenSize: CGRect = UIScreen.main.bounds
            let screenWidth = screenSize.width
            
            let appearance = SCLAlertView.SCLAppearance(
                kWindowWidth: screenWidth - 40 )

            let alert = SCLAlertView(appearance: appearance)
            alert.showInfo("MY PROFILE!", subTitle: FirstTimeMessages.myPRofileMessage, closeButtonTitle: "GOT IT!", colorStyle: 0x347aeb, animationStyle: .bottomToTop)
        }
    }
}

extension MyProfileViewController {
    func checkForNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(removeIcon), name: .seenAllNotifications, object: nil)
    }
    
    @objc func removeIcon(){
        self.tabBarController?.tabBar.items?[3].badgeValue = nil
    }
}
