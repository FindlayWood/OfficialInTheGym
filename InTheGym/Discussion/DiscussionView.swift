//
//  DiscussionView.swift
//  InTheGym
//
//  Created by Findlay Wood on 17/06/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class DiscussionView: UIView {
    
    var attachedWorkout: savedWorkoutDelegate?
    
    var bottomViewAnchor: NSLayoutConstraint!
    var commentFieldHeightAnchor: NSLayoutConstraint!
    private let placeholder = "add a reply..."
    private let placeholderColour: UIColor = Constants.darkColour
    private let stackViewSpacing: CGFloat = 10, constraintSpaicng: CGFloat = 10
    
    var replyType: replyType = .Text {
        didSet {
            textViewDidChange(commentTextField)
        }
    }
    
    var tableview: UITableView = {
        let tableview = UITableView()
        tableview.tableFooterView = UIView()
        tableview.rowHeight = UITableView.automaticDimension
        tableview.estimatedRowHeight = 90
        tableview.translatesAutoresizingMaskIntoConstraints = false
        return tableview
    }()
    
    var replyView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var attachmentButton: UIButton = {
       let button = UIButton()
        button.setImage(UIImage(named: "benchpress_icon"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    var attachmentLabel: UIButton = {
        let button = UIButton()
        button.backgroundColor = Constants.offWhiteColour
        button.titleLabel?.font = Constants.font
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.5
        button.layer.cornerRadius = 8
        button.layer.borderColor = Constants.darkColour.cgColor
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 5
        button.layer.shadowOpacity = 1.0
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    var removeAttachmentButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "Workout UnCompleted"), for: .normal)
        button.widthAnchor.constraint(equalToConstant: 30).isActive = true
        button.heightAnchor.constraint(equalToConstant: 30).isActive = true
        button.isHidden = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    lazy var commentTextField: UITextView = {
        let text = UITextView()
        text.backgroundColor = Constants.offWhiteColour
        text.text = placeholder
        text.textColor = placeholderColour
        text.isScrollEnabled = false
        text.delegate = self
        text.textContainer.maximumNumberOfLines = 0
        text.textContainer.lineBreakMode = .byWordWrapping
        text.font = .systemFont(ofSize: 16, weight: .semibold)
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
    
    lazy var stackView: UIStackView = {
       let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = stackViewSpacing
        stack.distribution = .equalSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }
    required init?(coder: NSCoder) {
        fatalError()
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    private func setUpView() {
        backgroundColor = .white
        addSubview(tableview)
        addSubview(replyView)
        stackView.addArrangedSubview(attachmentLabel)
        attachmentLabel.isHidden = true
        stackView.addArrangedSubview(commentTextField)
        replyView.addSubview(separatorView)
        replyView.addSubview(attachmentButton)
        replyView.addSubview(stackView)
        //replyView.addSubview(commentTextField)
        replyView.addSubview(sendButton)
        replyView.addSubview(removeAttachmentButton)
        constrainView()
    }
    private func constrainView() {
        bottomViewAnchor = replyView.bottomAnchor.constraint(equalTo: bottomAnchor)
        commentFieldHeightAnchor = commentTextField.heightAnchor.constraint(equalTo: replyView.heightAnchor, multiplier: 0.9)
        NSLayoutConstraint.activate([tableview.topAnchor.constraint(equalTo: topAnchor),
                                     tableview.leadingAnchor.constraint(equalTo: leadingAnchor),
                                     tableview.trailingAnchor.constraint(equalTo: trailingAnchor),
                                     tableview.bottomAnchor.constraint(equalTo: replyView.topAnchor),
        
                                     bottomViewAnchor,
                                     replyView.leadingAnchor.constraint(equalTo: leadingAnchor),
                                     replyView.trailingAnchor.constraint(equalTo: trailingAnchor),
                                     replyView.heightAnchor.constraint(equalToConstant: 60),
        
                                     separatorView.topAnchor.constraint(equalTo: replyView.topAnchor),
                                     separatorView.widthAnchor.constraint(equalTo: replyView.widthAnchor),
                                     separatorView.centerXAnchor.constraint(equalTo: replyView.centerXAnchor),
                                     separatorView.heightAnchor.constraint(equalToConstant: 1),
                                     
                                     attachmentButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
                                     attachmentButton.bottomAnchor.constraint(equalTo: replyView.bottomAnchor, constant: -5),
                                     attachmentButton.widthAnchor.constraint(equalToConstant: 35),
                                     attachmentButton.heightAnchor.constraint(equalToConstant: 35),
                                     
                                     attachmentLabel.heightAnchor.constraint(equalToConstant: 40),
                                     attachmentLabel.widthAnchor.constraint(equalTo: commentTextField.widthAnchor, constant: -18),
                                     
                                     stackView.leadingAnchor.constraint(equalTo: attachmentButton.trailingAnchor, constant: 5),
                                     stackView.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -10),
                                     stackView.topAnchor.constraint(equalTo: replyView.topAnchor, constant: 5),
                                     stackView.bottomAnchor.constraint(equalTo: replyView.bottomAnchor, constant: -5),
                                     commentTextField.widthAnchor.constraint(equalTo: stackView.widthAnchor),
                                     commentFieldHeightAnchor,
                                     
                                     removeAttachmentButton.centerYAnchor.constraint(equalTo: attachmentLabel.centerYAnchor),
                                     removeAttachmentButton.leadingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: 5),
                                     
                                     sendButton.trailingAnchor.constraint(equalTo: replyView.trailingAnchor, constant: -10),
                                     sendButton.widthAnchor.constraint(equalToConstant: 60),
                                     sendButton.bottomAnchor.constraint(equalTo: replyView.bottomAnchor,constant: -5)
        
        ])
        textViewDidChange(commentTextField)
    }
    
    func attachWorkout(_ workout: savedWorkoutDelegate) {
        replyType = .WorkoutAndText
        attachmentLabel.setTitle(workout.title!, for: .normal)
        attachmentLabel.isHidden = false
        removeAttachmentButton.isHidden = false
        attachedWorkout = workout
    }
    func removeAttachedWorkout() {
        replyType = .Text
        attachmentLabel.isHidden = true
        removeAttachmentButton.isHidden = true
        textViewDidChange(commentTextField)
        attachedWorkout = nil
    }
}
extension DiscussionView: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        let size = CGSize(width: textView.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        
        if estimatedSize.height > 150 {
            commentTextField.isScrollEnabled = true
        } else {
            commentTextField.isScrollEnabled = false
            commentFieldHeightAnchor.isActive = false
            replyView.constraints.forEach { constraint in
                if constraint.firstAttribute == .height {
                    let regularHeight = estimatedSize.height + constraintSpaicng
                    let expandedHeight = estimatedSize.height + constraintSpaicng + attachmentLabel.frame.height + stackViewSpacing
                    constraint.constant = replyType == .Text ? regularHeight : expandedHeight
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
            textView.textColor = .darkGray
        }
        
        if tableview.numberOfRows(inSection: 1) > 0 {
            let rowToScroll = tableview.numberOfRows(inSection: 1) - 1
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

enum replyType {
    case Text
    case WorkoutAndText
}
