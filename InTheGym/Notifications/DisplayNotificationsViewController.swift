//
//  DisplayNotificationsViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 15/03/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit
import Firebase
import EmptyDataSet_Swift

class DisplayNotificationsViewController: UIViewController {
    
    @IBOutlet weak var activityIndicator:UIActivityIndicatorView!
    @IBOutlet weak var tableview:UITableView!

    var adapter : DisplayNotificationsAdapter!
    
    var DBRef : DatabaseReference!
    
    lazy var viewModel: DisplayNotificationsViewModel = {
        return DisplayNotificationsViewModel(apiService: DBRef)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        DBRef = Database.database().reference()
        adapter = DisplayNotificationsAdapter(delegate: self)
        tableview.delegate = adapter
        tableview.dataSource = adapter
        tableview.register(UINib(nibName: "NotificationsTableViewCell", bundle: nil), forCellReuseIdentifier: "NotificationsTableViewCell")
        tableview.tableFooterView = UIView()
        tableview.emptyDataSetDelegate = adapter
        tableview.emptyDataSetSource = adapter
        
        initViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        let textAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes
        self.navigationController?.navigationBar.tintColor = .white
        navigationItem.title = "Notifications"
    }
    
    func initViewModel(){
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
        
        viewModel.fetchData()
    }
    
    func moveToPost(with post:PostProtocol){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let discussionVC = storyboard.instantiateViewController(withIdentifier: "DiscussionViewViewController") as! DiscussionViewViewController
        discussionVC.originalPost = post
        navigationController?.pushViewController(discussionVC, animated: true)
    }
    
    func moveToProfile(with user:Users){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let profileView = storyboard.instantiateViewController(withIdentifier: "PublicTimelineViewController") as! PublicTimelineViewController
        profileView.user = user
        navigationController?.pushViewController(profileView, animated: true)
    }
    

}

extension DisplayNotificationsViewController: DisplayNotificationsProtocol{
    
    func getData(at: IndexPath) -> NotificationTableViewModel {
        return viewModel.getData(at: at)
    }
    
    func itemSelected(at: IndexPath) {
        let notification = viewModel.getData(at: at)
        if notification.type == NotificationType.LikedPost || notification.type == NotificationType.Reply{
            let postID = notification.postID
            let postRef = Database.database().reference().child("Posts").child(postID!)
            postRef.observeSingleEvent(of: .value) { (snapshot) in
                guard let snap = snapshot.value as? [String:AnyObject] else {
                    return
                }
                
                var tempPost:PostProtocol!
                switch snap["type"] as! String {
                case "post":
                    tempPost = TimelinePostModel(snapshot: snapshot)
                case "createdNewWorkout":
                    tempPost = TimelineCreatedWorkoutModel(snapshot: snapshot)
                case "workout":
                    tempPost = TimelineCompletedWorkoutModel(snapshot: snapshot)
                default:
                    break
                }
                self.moveToPost(with: tempPost)   
            }
        } else if notification.type == NotificationType.groupLikedPost || notification.type == NotificationType.groupReply {
            let postID = notification.postID!
            let groupID = notification.groupID!
            let grouPostRef = Database.database().reference().child("GroupPosts").child(groupID).child(postID)
            grouPostRef.observeSingleEvent(of: .value) { (snapshot) in
                guard let snap = snapshot.value as? [String:AnyObject] else {
                    return
                }
                var tempPost:PostProtocol!
                switch snap["type"] as! String {
                case "post":
                    tempPost = DiscussionPost(snapshot: snapshot)
                case "createdNewWorkout":
                    tempPost = DiscussionCreatedWorkout(snapshot: snapshot)
                case "workout":
                    tempPost = DiscussionCompletedWorkout(snapshot: snapshot)
                default:
                    break
                }
                self.moveToPost(with: tempPost)
            }
        } else {
            let user = notification.from
            moveToProfile(with: user!)
        }

    }
    
    func retreiveNumberOfItems() -> Int {
        return viewModel.numberOfItems
    }
    
    func retreiveNumberOfSections() -> Int {
        return 1
    }
    
    
}
