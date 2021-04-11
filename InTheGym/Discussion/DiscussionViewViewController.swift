//
//  DiscussionViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 25/03/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class DiscussionViewViewController: UIViewController {
    
    @IBOutlet weak var tableview:UITableView!
    @IBOutlet weak var activityIndicator:UIActivityIndicatorView!
    
    var isGroup : Bool!
    var groupID : String!
    
    var adapter : DiscussionAdapter!
    
    var originalPost : PostProtocol!
    
    lazy var viewModel: DiscussionViewModel = {
        return DiscussionViewModel(originalPost: originalPost)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        adapter = DiscussionAdapter(delegate: self)
        tableview.dataSource = adapter
        tableview.delegate = adapter
        tableview.rowHeight = UITableView.automaticDimension
        tableview.estimatedRowHeight = 90
        tableview.register(UINib(nibName: "OriginalPostTableViewCell", bundle: nil), forCellReuseIdentifier: "OriginalPostTableViewCell")
        tableview.register(UINib(nibName: "OriginalCreatedWorkoutTableViewCell", bundle: nil), forCellReuseIdentifier: "OriginalCreatedWorkoutTableViewCell")
        tableview.register(UINib(nibName: "OriginalCompletedWorkoutTableViewCell", bundle: nil), forCellReuseIdentifier: "OriginalCompletedWorkoutTableViewCell")
        tableview.register(UINib(nibName: "ReplyTableViewCell", bundle: nil), forCellReuseIdentifier: "ReplyTableViewCell")
        tableview.tableFooterView = UIView()
        
        initViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        let textAttributes = [NSAttributedString.Key.foregroundColor:Constants.lightColour]
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes
        self.navigationController?.navigationBar.tintColor = Constants.lightColour
        navigationItem.title = "\(originalPost.username!)'s post"
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

}

extension DiscussionViewViewController: DiscussionProtocol, DiscussionTapProtocol{
    func getOriginalPost() -> PostProtocol {
        return originalPost
    }
    
    func getData(at: IndexPath) -> PostProtocol {
        return viewModel.getData(at: at)
    }
    
    func retreiveNumberOfItems() -> Int {
        return viewModel.numberOfItems
    }
    
    func retreiveNumberOfSections() -> Int {
        return 1
    }
    
    func itemSelected(at: IndexPath) {
        
    }
    
    func workoutTapped(on cell: UITableViewCell) {
        var workoutData : discoverWorkout!
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let displayWorkout = storyboard.instantiateViewController(withIdentifier: "DisplayWorkoutViewController") as! DisplayWorkoutViewController
        switch originalPost {
        case is DiscussionCreatedWorkout:
            let post = originalPost as! DiscussionCreatedWorkout
            workoutData = post.createdWorkout
            displayWorkout.selectedWorkout = workoutData
            self.navigationController?.pushViewController(displayWorkout, animated: true)
        case is DiscussionCompletedWorkout:
            let post = originalPost as! DiscussionCompletedWorkout
            workoutData = post.completedWorkout
            displayWorkout.selectedWorkout = workoutData
            self.navigationController?.pushViewController(displayWorkout, animated: true)
        default:
            break
        }
        
    
    }
    
    func likeButtonTapped(on cell: UITableViewCell, sender: UIButton) {
        viewModel.likePost(on: originalPost)
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
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let publicTimeline = storyboard.instantiateViewController(withIdentifier: "PublicTimelineViewController") as! PublicTimelineViewController
        let index = self.tableview.indexPath(for: cell)!
        if index.row == 0{
            UserIDToUser.transform(userID: originalPost.posterID!) { (user) in
                publicTimeline.user = user
                self.navigationController?.pushViewController(publicTimeline, animated: true)
            }
        }else{
            let posterID = viewModel.getData(at: index).posterID
            UserIDToUser.transform(userID: posterID!) { (user) in
                publicTimeline.user = user
                self.navigationController?.pushViewController(publicTimeline, animated: true)
            }
        }
    }
    
    func replyButtonTapped() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let replyVC = storyboard.instantiateViewController(withIdentifier: "ReplyViewController") as! ReplyViewController
        
        if isGroup == true {
            replyVC.isGroupPost = true
            replyVC.groupID = self.groupID
        } else {
            replyVC.isGroupPost = false
        }
        replyVC.postID = originalPost.postID
        replyVC.posterID = originalPost.posterID
        replyVC.modalTransitionStyle = .coverVertical
        replyVC.modalPresentationStyle = .formSheet
        self.present(replyVC, animated: true, completion: nil)
    }
    
    
}
