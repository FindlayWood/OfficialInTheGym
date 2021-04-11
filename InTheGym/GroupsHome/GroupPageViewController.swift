//
//  GroupPageViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 06/04/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit
import SCLAlertView
import EmptyDataSet_Swift

class GroupPageViewController: UIViewController {
    
    @IBOutlet weak var collection:UICollectionView!
    @IBOutlet weak var groupTitle:UILabel!
    @IBOutlet weak var groupDescription:UITextView!
    @IBOutlet weak var tableview:UITableView!
    @IBOutlet weak var activityIndicator:UIActivityIndicatorView!
    
    var refreshControl : UIRefreshControl!
    
    var group : groupModel!
    
    var adapter : GroupPageAdapter!
    
    lazy var viewModel : GroupPageViewModel = {
        return GroupPageViewModel(groupID: group.groupID, groupLeader: group.groupLeader)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        adapter = GroupPageAdapter(delegate:self)
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
        tableview.emptyDataSetSource = adapter
        tableview.emptyDataSetDelegate = adapter
        
        collection.delegate = adapter
        collection.dataSource = adapter
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        layout.minimumInteritemSpacing = 0
        collection.collectionViewLayout = layout
        collection.register(UINib(nibName: "GroupMemberCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "GroupMemberCollectionViewCell")

        initUI()
        initRefreshControl()
        initViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        let textAttributes = [NSAttributedString.Key.foregroundColor:Constants.lightColour]
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes
        self.navigationController?.navigationBar.tintColor = Constants.lightColour
    }
    
    func initUI(){
        self.navigationItem.title = group.groupTitle
        self.groupDescription.text = group.groupDescription
        let postButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(post))
        self.navigationItem.rightBarButtonItem = postButton
    }
    
    func initRefreshControl(){
        refreshControl = UIRefreshControl()
        refreshControl.tintColor = .white
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        self.tableview.refreshControl = refreshControl
    }
    
    @objc func handleRefresh(){
        viewModel.fetchGroupPosts()
    }

    func initViewModel(){
        
        viewModel.loadingStatusClosure = { [weak self] () in
            let isLoading = self?.viewModel.isLoading ?? false
            if isLoading{
                self?.activityIndicator.startAnimating()
                UIView.animate(withDuration: 0.2, animations: {
                    self?.tableview.alpha = 1.0
                })
            } else {
                self?.activityIndicator.stopAnimating()
                UIView.animate(withDuration: 0.2, animations: {
                    self?.tableview.alpha = 1.0
                })
            }
            
        }
        
        viewModel.postsLoadedClosure = { [weak self] () in
            DispatchQueue.main.async {
                self?.tableview.reloadData()
                if self!.tableview.refreshControl!.isRefreshing{
                    self?.tableview.refreshControl?.endRefreshing()
                }
            }
        }
        
        viewModel.membersLoadedClosure = { [weak self] () in
            DispatchQueue.main.async {
                self?.collection.reloadData()
            }
        }
        
        viewModel.fetchGroupPosts()
        viewModel.fetchMembers()
    }
    
    @objc func post(){
        if ViewController.admin {
            self.presentAddOptions()
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let postVC = storyboard.instantiateViewController(withIdentifier: "MakePostViewController") as! MakePostViewController
            postVC.modalTransitionStyle = .coverVertical
            postVC.modalPresentationStyle = .fullScreen
            postVC.groupBool = true
            postVC.playerPost = false
            postVC.groupName = group.groupTitle
            postVC.groupID = group.groupID
            postVC.delegate = self
            self.navigationController?.present(postVC, animated: true, completion: nil)
        }

    }
    
    func presentAddOptions(){
        let screenSize: CGRect = UIScreen.main.bounds
        let screenWidth = screenSize.width
        
        let appearance = SCLAlertView.SCLAppearance(
            kWindowWidth: screenWidth - 40, showCloseButton: false)
        let options = SCLAlertView(appearance: appearance)
        options.addButton("Post") {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let postVC = storyboard.instantiateViewController(withIdentifier: "MakePostViewController") as! MakePostViewController
            postVC.modalTransitionStyle = .coverVertical
            postVC.modalPresentationStyle = .fullScreen
            postVC.groupBool = true
            postVC.playerPost = false
            postVC.groupName = self.group.groupTitle
            postVC.groupID = self.group.groupID
            postVC.delegate = self
            self.navigationController?.present(postVC, animated: true, completion: nil)
        }
        options.addButton("Workout") {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let postVC = storyboard.instantiateViewController(withIdentifier: "AddWorkoutHomeViewController") as! AddWorkoutHomeViewController
            AddWorkoutHomeViewController.groupBool = true
            postVC.playerBool = false
            postVC.groupID = self.group.groupID
            let myGroup = DispatchGroup()
            var memberIDs = [String]()
            for member in self.viewModel.groupMembers{
                myGroup.enter()
                memberIDs.append(member.uid!)
                myGroup.leave()
            }
            myGroup.notify(queue: .main){
                postVC.groupPlayers = memberIDs
                self.navigationController?.pushViewController(postVC, animated: true)
            }
            
        }
        options.showInfo("What to add?", subTitle: "Would you like to add a post or add a workout to all members?", colorStyle: 0x347aeb, animationStyle: .bottomToTop)
    }

}

extension GroupPageViewController : GroupPageProtocol{
    func getPostData(at indexPath:IndexPath) -> PostProtocol {
        return viewModel.getPostData(at: indexPath)
    }
    
    func getMemberData(at indexPath: IndexPath) -> Users {
        return viewModel.getMemberData(at: indexPath)
    }
    
    func postSelected(at indexPath: IndexPath) {
        // go to discussion page
        let post = viewModel.getPostData(at: indexPath)
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
            discussionVC.isGroup = true
            discussionVC.groupID = group.groupID
            self.navigationController?.pushViewController(discussionVC, animated: true)
        }
    }
    
    func memberSelected(at indexPath: IndexPath) {
        // go to user profile
        let member = getMemberData(at: indexPath)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let publicTimeline = storyboard.instantiateViewController(withIdentifier: "PublicTimelineViewController") as! PublicTimelineViewController
        UserIDToUser.transform(userID: member.uid!) { (user) in
            publicTimeline.user = user
            self.navigationController?.pushViewController(publicTimeline, animated: true)
        }
    }
    
    func retreiveNumberOfPosts() -> Int {
        return viewModel.numberOfPosts
    }
    
    func retreiveNumberOfMembers() -> Int {
        return viewModel.numberOfMembers
    }
    
    func madeAPost() {
        viewModel.fetchGroupPosts()
    }
}

extension GroupPageViewController : TimelineTapProtocol {
    func likeButtonTapped(on cell: UITableViewCell, sender: UIButton, label: UILabel) {
        let index = self.tableview.indexPath(for: cell)!
        let post = viewModel.getPostData(at: index)
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
    
    func workoutTapped(on cell: UITableViewCell) {
        let index = self.tableview.indexPath(for: cell)!
        let post = viewModel.getPostData(at:index)
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
    
    func userTapped(on cell: UITableViewCell) {
        let index = self.tableview.indexPath(for: cell)!
        let post = viewModel.getPostData(at: index)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let publicTimeline = storyboard.instantiateViewController(withIdentifier: "PublicTimelineViewController") as! PublicTimelineViewController
        let posterID = post.posterID
        if posterID != viewModel.userID {
            UserIDToUser.transform(userID: posterID!) { (user) in
                publicTimeline.user = user
                self.navigationController?.pushViewController(publicTimeline, animated: true)
            }
        }
    }
}
