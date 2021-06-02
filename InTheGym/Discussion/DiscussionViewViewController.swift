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
    
    //@IBOutlet weak var tableview:UITableView!
    @IBOutlet weak var activityIndicator:UIActivityIndicatorView!
    
    var tableview: UITableView = {
        let tableview = UITableView()
        tableview.tableFooterView = UIView()
        tableview.rowHeight = UITableView.automaticDimension
        tableview.estimatedRowHeight = 90
        tableview.translatesAutoresizingMaskIntoConstraints = false
        return tableview
    }()
    
    var bottomView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var bottomViewAnchor: NSLayoutConstraint!
    var commentFieldHeightAnchor: NSLayoutConstraint!
    private let placeholder = "add a reply..."
    private let placeholderColour: UIColor = Constants.darkColour
    
    lazy var commentTextField: UITextView = {
        let text = UITextView()
        text.backgroundColor = Constants.offWhiteColour
        text.text = placeholder
        text.textColor = placeholderColour
        text.isScrollEnabled = false
        text.delegate = self
        text.textContainer.maximumNumberOfLines = 0
        text.textContainer.lineBreakMode = .byWordWrapping
        text.font = .systemFont(ofSize: 16, weight: .medium)
        text.textContainerInset = UIEdgeInsets(top: 8, left: 5, bottom: 8, right: 5)
        text.sizeToFit()
        text.layer.cornerRadius = 18
        text.layer.borderWidth = 0.5
        text.layer.borderColor = Constants.darkColour.cgColor
        text.tintColor = Constants.darkColour
        text.translatesAutoresizingMaskIntoConstraints = false
        return text
    }()
    
    var sendButton: UIButton = {
        let button = UIButton()
        button.setTitle("Send", for: .normal)
        button.setTitleColor(.lightGray, for: .normal)
        button.isUserInteractionEnabled = false
        button.addTarget(self, action: #selector(sendPressed(_:)), for: .touchUpInside)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0.5
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
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
        tableview.dataSource = adapter
        tableview.delegate = adapter
        tableview.register(UINib(nibName: "OriginalPostTableViewCell", bundle: nil), forCellReuseIdentifier: "OriginalPostTableViewCell")
        tableview.register(UINib(nibName: "OriginalCreatedWorkoutTableViewCell", bundle: nil), forCellReuseIdentifier: "OriginalCreatedWorkoutTableViewCell")
        tableview.register(UINib(nibName: "OriginalCompletedWorkoutTableViewCell", bundle: nil), forCellReuseIdentifier: "OriginalCompletedWorkoutTableViewCell")
        tableview.register(UINib(nibName: "ReplyTableViewCell", bundle: nil), forCellReuseIdentifier: "ReplyTableViewCell")
        tableview.separatorStyle = .none
        
        initUI()
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
    
    func initUI(){
        view.addSubview(tableview)
        view.addSubview(bottomView)
        tableview.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableview.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableview.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableview.bottomAnchor.constraint(equalTo: bottomView.topAnchor).isActive = true
        let bottomAnchor = view.safeAreaLayoutGuide.bottomAnchor
        bottomViewAnchor = bottomView.bottomAnchor.constraint(equalTo: bottomAnchor)
        bottomViewAnchor.isActive = true
        bottomView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        bottomView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        bottomView.addSubview(separatorView)
        bottomView.addSubview(commentTextField)
        bottomView.addSubview(sendButton)
        separatorView.topAnchor.constraint(equalTo: bottomView.topAnchor).isActive = true
        separatorView.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        separatorView.widthAnchor.constraint(equalTo: bottomView.widthAnchor).isActive = true
        separatorView.centerXAnchor.constraint(equalTo: bottomView.centerXAnchor).isActive = true
        sendButton.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor, constant: -10).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: bottomView.centerYAnchor).isActive = true
        commentTextField.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor, constant: 10).isActive = true
        commentTextField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -10).isActive = true
        commentTextField.centerYAnchor.constraint(equalTo: bottomView.centerYAnchor).isActive = true
        commentFieldHeightAnchor = commentTextField.heightAnchor.constraint(equalTo: bottomView.heightAnchor, multiplier: 0.9)
        commentFieldHeightAnchor.isActive = true
        textViewDidChange(commentTextField)
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
            
            bottomViewAnchor.constant = isKeyboardShowing ? -keyboardFrame!.height + tabBarHeight! : 0
            
            UIView.animate(withDuration: 0) {
                self.view.layoutIfNeeded()
            }
        }

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
        
        viewModel.replyAddedClosure = { [weak self] () in
            guard let self = self else {return}
            DispatchQueue.main.async {
                self.originalPost.replyCount = (self.originalPost.replyCount ?? 0) + 1
                self.tableview.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
            }
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
        commentTextField.resignFirstResponder()
    }
    
    func replyPosted() {
        self.originalPost.replyCount = (self.originalPost.replyCount ?? 0) + 1
        self.tableview.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
        //self.viewModel.fetchData()
    }
}
extension DiscussionViewViewController: DiscussionTapProtocol {
    
    func workoutTapped(on cell: UITableViewCell) {
        var workoutData : discoverWorkout!
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let displayWorkout = storyboard.instantiateViewController(withIdentifier: "DisplayWorkoutViewController") as! DisplayWorkoutViewController
        displayWorkout.hidesBottomBarWhenPushed = true
        switch originalPost {
        case is DiscussionCreatedWorkout:
            let post = originalPost as! DiscussionCreatedWorkout
            workoutData = post.createdWorkout
            DisplayWorkoutViewController.selectedWorkout = workoutData
            self.navigationController?.pushViewController(displayWorkout, animated: true)
        case is DiscussionCompletedWorkout:
            let post = originalPost as! DiscussionCompletedWorkout
            workoutData = post.completedWorkout
            DisplayWorkoutViewController.selectedWorkout = workoutData
            self.navigationController?.pushViewController(displayWorkout, animated: true)
        default:
            break
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
        let index = self.tableview.indexPath(for: cell)!
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
            viewModel.addGroupReply(commentTextField.text.trimTrailingWhiteSpaces())
        } else {
            viewModel.addReply(commentTextField.text.trimTrailingWhiteSpaces())
        }
        commentTextField.text = nil
        textViewDidEndEditing(commentTextField)
        commentTextField.resignFirstResponder()
    }
    
    
}

extension DiscussionViewViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        let size = CGSize(width: textView.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        
        if estimatedSize.height > 150 {
            commentTextField.isScrollEnabled = true
        } else {
            commentTextField.isScrollEnabled = false
            commentFieldHeightAnchor.isActive = false
            bottomView.constraints.forEach { constraint in
                if constraint.firstAttribute == .height {
                    constraint.constant = estimatedSize.height + ((estimatedSize.height / 9) * 3)
                    commentFieldHeightAnchor = commentTextField.heightAnchor.constraint(equalToConstant: estimatedSize.height)
                    commentFieldHeightAnchor.isActive = true
                }
            }
        }
        
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || textView.text == placeholder  {
            sendButton.setTitleColor(.lightGray, for: .normal)
            sendButton.isUserInteractionEnabled = false
        } else {
            sendButton.setTitleColor(Constants.lightColour, for: .normal)
            sendButton.isUserInteractionEnabled = true
        }
        

    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == placeholderColour {
            textView.text = nil
            textView.textColor = .black
        }
        
        if retreiveNumberOfItems() != 0 {
            let rowToScroll = retreiveNumberOfItems() - 1
            tableview.scrollToRow(at: IndexPath(row: rowToScroll, section: 1), at: .bottom, animated: true)
        }
        
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimTrailingWhiteSpaces().isEmpty {
            textView.textColor = placeholderColour
            textView.text = placeholder
        }
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 5, bottom: 8, right: 5)
        textView.text = textView.text.trimTrailingWhiteSpaces()
        textViewDidChange(textView)
    }
}
