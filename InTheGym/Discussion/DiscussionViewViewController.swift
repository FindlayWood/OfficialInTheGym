//
//  DiscussionViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 25/03/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class DiscussionViewViewController: UIViewController, Storyboarded {
    
    weak var coordinator : DiscussionCoordinator?
    
    var display = DiscussionView()
    var savedWorkoutView = DiscussionSavedWorkoutDisplayView()
    var flashView = FlashView()
    var bottomViewHeight = Constants.screenSize.height * 0.5
    
    //@IBOutlet weak var tableview:UITableView!
    @IBOutlet weak var activityIndicator:UIActivityIndicatorView!
    
    var isGroup : Bool!
    var groupID : String!
    
    // pull to refresh the data on the screen
    var refreshControl : UIRefreshControl!
    
    var adapter : DiscussionAdapter!
    
    var originalPost : PostProtocol!
    
    lazy var viewModel: DiscussionViewModel = {
        return DiscussionViewModel(originalPost: originalPost)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        adapter = DiscussionAdapter(delegate: self)
        display.tableview.dataSource = adapter
        display.tableview.delegate = adapter
        display.tableview.register(UINib(nibName: "OriginalPostTableViewCell", bundle: nil), forCellReuseIdentifier: "OriginalPostTableViewCell")
        display.tableview.register(UINib(nibName: "OriginalCreatedWorkoutTableViewCell", bundle: nil), forCellReuseIdentifier: "OriginalCreatedWorkoutTableViewCell")
        display.tableview.register(UINib(nibName: "OriginalCompletedWorkoutTableViewCell", bundle: nil), forCellReuseIdentifier: "OriginalCompletedWorkoutTableViewCell")
        display.tableview.register(UINib(nibName: "ReplyTableViewCell", bundle: nil), forCellReuseIdentifier: "ReplyTableViewCell")
        display.tableview.register(DiscussionReplyAttachedWorkout.self, forCellReuseIdentifier: "AttachedWorkoutReplyCell")
        display.tableview.separatorStyle = .none
        display.sendButton.addTarget(self, action: #selector(sendPressed(_:)), for: .touchUpInside)
        display.attachmentButton.addTarget(self, action: #selector(attachWorkoutTapped), for: .touchUpInside)
        display.removeAttachmentButton.addTarget(self, action: #selector(removeAttachedWorkout), for: .touchUpInside)
        
        //initUI()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        display.frame = CGRect(x: 0, y: view.safeAreaInsets.top, width: view.frame.width, height: view.frame.height - view.safeAreaInsets.top - view.safeAreaInsets.bottom)
        view.addSubview(display)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if isMovingToParent{
            initViewModel()
        }
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        let textAttributes = [NSAttributedString.Key.foregroundColor:Constants.lightColour]
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes
        self.navigationController?.navigationBar.tintColor = Constants.lightColour
        navigationItem.title = "\(originalPost.username!)'s post"
        setupKeyBoardObservers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if isMovingFromParent{
            viewModel.removeObserver()
        }
        NotificationCenter.default.removeObserver(self)
    }
    
    func setupKeyBoardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardObervers(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardObervers(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func handleKeyboardObervers(notification: Notification) {

        if let userInfo = notification.userInfo {

            let isKeyboardShowing = notification.name == UIResponder.keyboardWillShowNotification
            let isTabBarHidden = tabBarController?.tabBar.isHidden ?? true
            
            let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
            let tabBarHeight = isTabBarHidden ? view.safeAreaInsets.bottom : self.tabBarController?.tabBar.frame.height
            
            display.bottomViewAnchor.constant = isKeyboardShowing ? -keyboardFrame!.height + tabBarHeight! : 0
            if isKeyboardShowing {
                if savedWorkoutView.flashView != nil {
                    savedWorkoutView.remove()
                }
            }
            
            UIView.animate(withDuration: 0) {
                self.display.layoutIfNeeded()
            }
        }
    }
    
    @objc func attachWorkoutTapped() {
        display.commentTextField.resignFirstResponder()
        savedWorkoutView.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: bottomViewHeight)
        flashView.frame = CGRect(x: 0, y: 0 - view.safeAreaInsets.top, width: view.frame.width, height: view.frame.height - view.safeAreaInsets.bottom - display.replyView.frame.height)
        flashView.alpha = 0
        savedWorkoutView.flashView = flashView
        display.addSubview(flashView)
        display.addSubview(savedWorkoutView)
        let yOffset = Constants.screenSize.height - bottomViewHeight - view.safeAreaInsets.top - view.safeAreaInsets.bottom - display.replyView.frame.height
        let showFrame = CGRect(x: 0, y: yOffset, width: view.frame.width, height: bottomViewHeight)
        UIView.animate(withDuration: 0.2) {
            self.savedWorkoutView.frame = showFrame
            self.flashView.alpha = 0.4
            self.flashView.isUserInteractionEnabled = true
        }
    }
    
    @objc func removeAttachedWorkout() {
        display.removeAttachedWorkout()
    }
    
    
    func initViewModel(){
        
        // Setup for reloadTableViewClosure
        viewModel.reloadTableViewClosure = { [weak self] () in
            DispatchQueue.main.async {
                self?.display.tableview.reloadData()
            }
        }
        
        // Setup for updateLoadingStatusClosure
        viewModel.updateLoadingStatusClosure = { [weak self] () in
            DispatchQueue.main.async {
                let isLoading = self?.viewModel.isLoading ?? false
                if isLoading {
                    self?.activityIndicator.startAnimating()
                    UIView.animate(withDuration: 0.2, animations: {
                        self?.display.tableview.alpha = 0.0
                    })
                } else {
                    self?.activityIndicator.stopAnimating()
                    UIView.animate(withDuration: 0.2, animations: {
                        self?.display.tableview.alpha = 1.0
                    })
                }
            }
        }
        
        viewModel.replyAddedClosure = { [weak self] () in
            guard let self = self else {return}
            DispatchQueue.main.async {
                self.originalPost.replyCount = (self.originalPost.replyCount ?? 0) + 1
                self.display.tableview.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
            }
        }
        
        savedWorkoutView.savedWorkoutSelected = { [weak self] selectedWorkout in
            guard let self = self else {return}
            self.display.attachWorkout(selectedWorkout)
        }
        
        viewModel.fetchData()
    }

}

extension DiscussionViewViewController: DiscussionProtocol{
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
        return 2
    }
    
    func itemSelected(at: IndexPath) {
        display.commentTextField.resignFirstResponder()
    }
    
    func replyPosted() {
        self.originalPost.replyCount = (self.originalPost.replyCount ?? 0) + 1
        self.display.tableview.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
        //self.viewModel.fetchData()
    }
}
extension DiscussionViewViewController: DiscussionTapProtocol {
    
    func workoutTapped(on cell: UITableViewCell) {
        guard let index = display.tableview.indexPath(for: cell) else {return}
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let displayWorkout = storyboard.instantiateViewController(withIdentifier: "DisplayWorkoutViewController") as! DisplayWorkoutViewController
        displayWorkout.hidesBottomBarWhenPushed = true
        if index == IndexPath(row: 0, section: 0) {
            var workoutData : discoverWorkout!
            switch originalPost {
            case is DiscussionCreatedWorkout:
                let post = originalPost as! DiscussionCreatedWorkout
                workoutData = post.createdWorkout
                self.coordinator?.showWorkout(with: workoutData)
            case is DiscussionCompletedWorkout:
                let post = originalPost as! DiscussionCompletedWorkout
                workoutData = post.completedWorkout
                self.coordinator?.showWorkout(with: workoutData)
            default:
                break
            }
        } else {
            let reply = viewModel.getData(at: index) as! DiscussionReplyPlusWorkout
            guard let savedWorkoutID = reply.attachedWorkoutSavedID else {return}
            FirebaseAPILoader.shared.loadDiscoverWorkout(with: savedWorkoutID) { [weak self] result in
                guard let self = self else {return}
                switch result {
                case .success(let workout):
                    self.coordinator?.showWorkout(with: workout)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func likeButtonTapped(on cell: UITableViewCell, sender: UIButton, label: UILabel) {
        let selection = UISelectionFeedbackGenerator()
        selection.prepare()
        selection.selectionChanged()
        
        if #available(iOS 13.0, *) {
            UIView.transition(with: sender, duration: 0.3, options: .transitionCrossDissolve) {
                sender.setImage(UIImage(systemName: "star.fill"), for: .normal)
            } completion: { _ in
                sender.isUserInteractionEnabled = false
            }

        }
    
        viewModel.isLiked() { (result) in
            switch result {
            
            case .success(let liked):
                if !liked {
                    self.viewModel.likePost()
                    let likeCount = Int(label.text!)! + 1
                    label.text = likeCount.description
                }
                
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func userTapped(on cell: UITableViewCell) {
        let index = self.display.tableview.indexPath(for: cell)!
        if index.section == 0{
            if originalPost.posterID! != viewModel.userID {
                UserIDToUser.transform(userID: originalPost.posterID!) { (user) in
                    self.coordinator?.showUser(with: user)
                }
            }
        } else {
            let posterID = viewModel.getData(at: index).posterID
            if posterID != viewModel.userID {
                UserIDToUser.transform(userID: posterID!) { (user) in
                    self.coordinator?.showUser(with: user)
                }
            }
        }
    }
    
    @objc func sendPressed( _ sender: UIButton) {
        
        if isGroup {
            viewModel.addGroupReply(display.commentTextField.text.trimTrailingWhiteSpaces(), attachment: display.attachedWorkout, groupID: groupID)
        } else {
            viewModel.addReply(display.commentTextField.text.trimTrailingWhiteSpaces(), attachment: display.attachedWorkout)
        }
        display.commentTextField.text = nil
        display.removeAttachedWorkout()
        display.textViewDidEndEditing(display.commentTextField)
        display.commentTextField.resignFirstResponder()
    }
    
    
}
