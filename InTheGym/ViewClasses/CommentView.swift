//
//  CommentView.swift
//  InTheGym
//
//  Created by Findlay Wood on 15/12/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class CommentView: UIView {
    
    // MARK: - Published
    @Published var commentText: String = ""
    var sendPressed = PassthroughSubject<Void,Never>()

    // MARK: - Properties
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
    
    // MARK: - Subviews
    var attachmentButton: UIButton = {
       let button = UIButton()
        button.setImage(UIImage(systemName: "paperclip", withConfiguration: UIImage.SymbolConfiguration(scale: .large)), for: .normal)
        button.imageView?.tintColor = .darkColour
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    var attachmentLabel: UIButton = {
        let button = UIButton()
        button.backgroundColor = .offWhiteColour
        button.titleLabel?.font = Constants.font
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.5
        button.layer.cornerRadius = 8
        button.layer.borderColor = UIColor.darkColour.cgColor
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 5
        button.layer.shadowOpacity = 1.0
        button.isHidden = true
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
        button.setTitleColor(.lightGray, for: .disabled)
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
       let stack = UIStackView(arrangedSubviews: [attachmentLabel, commentTextField])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = stackViewSpacing
        //stack.distribution = .equalSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
}
// MARK: - Configure
private extension CommentView {
    func setupUI() {
        backgroundColor = .white
        addSubview(separatorView)
        addSubview(attachmentButton)
        addSubview(stackView)
        addSubview(sendButton)
        addSubview(removeAttachmentButton)
        configureUI()
    }
    
    func configureUI() {
        commentFieldHeightAnchor = commentTextField.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.9)
        NSLayoutConstraint.activate([
            separatorView.topAnchor.constraint(equalTo: topAnchor),
            separatorView.widthAnchor.constraint(equalTo: widthAnchor),
            separatorView.centerXAnchor.constraint(equalTo: centerXAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1),
            
            attachmentButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            attachmentButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5),
            attachmentButton.widthAnchor.constraint(equalToConstant: 35),
            attachmentButton.heightAnchor.constraint(equalToConstant: 35),
            
            sendButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            sendButton.widthAnchor.constraint(equalToConstant: 60),
            sendButton.bottomAnchor.constraint(equalTo: bottomAnchor,constant: -5),
            
            attachmentLabel.heightAnchor.constraint(equalToConstant: 40),
            attachmentLabel.widthAnchor.constraint(equalTo: commentTextField.widthAnchor, constant: -18),
            
            stackView.leadingAnchor.constraint(equalTo: attachmentButton.trailingAnchor, constant: 5),
            stackView.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -10),
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5),
            commentTextField.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            commentFieldHeightAnchor,
            
            removeAttachmentButton.centerYAnchor.constraint(equalTo: attachmentLabel.centerYAnchor),
            removeAttachmentButton.leadingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: 5)

        ])
        textViewDidChange(commentTextField)
    }
}

// MARK: - Public Attachments
extension CommentView {
    public func attachWorkout(_ workout: SavedWorkoutModel) {
        replyType = .WorkoutAndText
        attachmentLabel.setTitle(workout.title, for: .normal)
        attachmentLabel.isHidden = false
        removeAttachmentButton.isHidden = false
        //attachedWorkout = workout
    }
    public func removeAttachedWorkout() {
        replyType = .Text
        attachmentLabel.isHidden = true
        removeAttachmentButton.isHidden = true
        textViewDidChange(commentTextField)
        //attachedWorkout = nil
    }
    public func resetView() {
        replyType = .Text
        attachmentLabel.isHidden = true
        removeAttachmentButton.isHidden = true
        textViewDidChange(commentTextField)
    }
}

extension CommentView: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        let size = CGSize(width: textView.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        
        if estimatedSize.height > 150 {
            commentTextField.isScrollEnabled = true
        } else {
            commentTextField.isScrollEnabled = false
            commentFieldHeightAnchor.isActive = false
            constraints.forEach { constraint in
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
//            sendButton.isEnabled = false
            sendButton.setTitleColor(.lightGray, for: .normal)
            sendButton.isUserInteractionEnabled = false
        } else {
//            sendButton.isEnabled = true
            sendButton.setTitleColor(Constants.lightColour, for: .normal)
            sendButton.isUserInteractionEnabled = true
        }
        

    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == placeholderColour {
            textView.text = nil
            textView.textColor = .darkGray
        }
        
//        if tableview.numberOfRows(inSection: 1) > 0 {
//            let rowToScroll = tableview.numberOfRows(inSection: 1) - 1
//            tableview.scrollToRow(at: IndexPath(row: rowToScroll, section: 1), at: .bottom, animated: true)
//        }
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
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newString = (textView.text! as NSString).replacingCharacters(in: range, with: text).trimTrailingWhiteSpaces()
        commentText = newString
        return true
    }
}

