//
//  DiscussionReplyAttachedWorkout.swift
//  InTheGym
//
//  Created by Findlay Wood on 22/06/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class DiscussionReplyAttachedWorkout: UITableViewCell, DiscussionCellConfigurable {
    
    var delegate: DiscussionTapProtocol!
    
    let profileImageDimension: CGFloat = 40
    let usernameHeight: CGFloat = 24
    let timeLabelHeight: CGFloat = 12
    let workoutViewHeight: CGFloat = 108
    let iconDimension: CGFloat = 30
    let creatorIcon = "coach_icon"
    let exerciseCountIcon = "dumbbell_icon"
    
    lazy var profileImage: UIButton = {
        let image = UIButton()
        image.backgroundColor = .lightGray
        image.layer.masksToBounds = true
        image.layer.cornerRadius = profileImageDimension / 2
        image.isUserInteractionEnabled = true
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    var username: UIButton = {
        let button = UIButton()
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        button.isUserInteractionEnabled = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var timeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10)
        label.textColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var textView: UITextView = {
        let text = UITextView()
        text.font = .systemFont(ofSize: 16, weight: .semibold)
        text.textColor = .darkGray
        text.backgroundColor = Constants.offWhiteColour
        text.layer.cornerRadius = 5
        text.sizeToFit()
        text.textContainerInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        text.isScrollEnabled = false
        text.isUserInteractionEnabled = false
        text.translatesAutoresizingMaskIntoConstraints = false
        return text
    }()
    
    var attachedWorkoutView: UIView = {
        let view = UIView()
        view.backgroundColor = Constants.offWhiteColour
        view.layer.cornerRadius = 10
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        view.layer.shadowRadius = 4.0
        view.layer.shadowOpacity = 1.0
        view.layer.masksToBounds = false
        view.isUserInteractionEnabled = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var attachedWorkoutTitle: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .black
        label.isUserInteractionEnabled = false
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var attachedWorkoutCreator: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var attachedWorkoutCreatorImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: creatorIcon)
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    var attachedWorkoutExerciseCount: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var attachedWorkoutExerciseCountImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: exerciseCountIcon)
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpView()
        addTapToView()
    }
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func setUpView() {
        selectionStyle = .none
        contentView.addSubview(profileImage)
        contentView.addSubview(username)
        contentView.addSubview(timeLabel)
        contentView.addSubview(textView)
        contentView.addSubview(attachedWorkoutView)
        attachedWorkoutView.addSubview(attachedWorkoutTitle)
        attachedWorkoutView.addSubview(attachedWorkoutCreator)
        attachedWorkoutView.addSubview(attachedWorkoutCreatorImage)
        attachedWorkoutView.addSubview(attachedWorkoutExerciseCount)
        attachedWorkoutView.addSubview(attachedWorkoutExerciseCountImage)
        constrainView()
    }
    
    func constrainView() {
        NSLayoutConstraint.activate([profileImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                                     profileImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
                                     profileImage.heightAnchor.constraint(equalToConstant: profileImageDimension),
                                     profileImage.widthAnchor.constraint(equalToConstant: profileImageDimension),
                                     
                                     username.leadingAnchor.constraint(equalTo: profileImage.trailingAnchor, constant: 8),
                                     username.topAnchor.constraint(equalTo: profileImage.topAnchor),
                                     username.heightAnchor.constraint(equalToConstant: usernameHeight),
                                     
                                     timeLabel.centerYAnchor.constraint(equalTo: username.centerYAnchor),
                                     timeLabel.leadingAnchor.constraint(equalTo: username.trailingAnchor, constant: 5),
                                     timeLabel.heightAnchor.constraint(equalToConstant: timeLabelHeight),
                                     
                                     attachedWorkoutView.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 10),
                                     attachedWorkoutView.leadingAnchor.constraint(equalTo: textView.leadingAnchor),
                                     attachedWorkoutView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
                                     attachedWorkoutView.heightAnchor.constraint(equalToConstant: workoutViewHeight),
                                     attachedWorkoutView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
                                     
                                     
                                     attachedWorkoutTitle.topAnchor.constraint(equalTo: attachedWorkoutView.topAnchor, constant: 8),
                                     attachedWorkoutTitle.leadingAnchor.constraint(equalTo: attachedWorkoutView.leadingAnchor, constant: 8),
                                     
                                     attachedWorkoutCreatorImage.topAnchor.constraint(equalTo: attachedWorkoutTitle.bottomAnchor, constant: 4),
                                     attachedWorkoutCreatorImage.leadingAnchor.constraint(equalTo: attachedWorkoutView.leadingAnchor, constant: 8),
                                     attachedWorkoutCreatorImage.heightAnchor.constraint(equalToConstant: iconDimension),
                                     attachedWorkoutCreatorImage.widthAnchor.constraint(equalToConstant: iconDimension),
                                     
                                     attachedWorkoutCreator.centerYAnchor.constraint(equalTo: attachedWorkoutCreatorImage.centerYAnchor),
                                     attachedWorkoutCreator.leadingAnchor.constraint(equalTo: attachedWorkoutCreatorImage.trailingAnchor, constant: 10),
                                     
                                     attachedWorkoutExerciseCountImage.topAnchor.constraint(equalTo: attachedWorkoutCreatorImage.bottomAnchor, constant: 6),
                                     attachedWorkoutExerciseCountImage.leadingAnchor.constraint(equalTo: attachedWorkoutView.leadingAnchor, constant: 8),
                                     attachedWorkoutExerciseCountImage.heightAnchor.constraint(equalToConstant: iconDimension),
                                     attachedWorkoutExerciseCountImage.widthAnchor.constraint(equalToConstant: iconDimension),
                                     
                                     attachedWorkoutExerciseCount.centerYAnchor.constraint(equalTo: attachedWorkoutExerciseCountImage.centerYAnchor),
                                     attachedWorkoutExerciseCount.leadingAnchor.constraint(equalTo: attachedWorkoutExerciseCountImage.trailingAnchor, constant: 10),
                                     
                                     textView.leadingAnchor.constraint(equalTo: username.leadingAnchor),
                                     textView.topAnchor.constraint(equalTo: username.bottomAnchor, constant: 5),
                                     textView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -20)
        
        ])
        textView.sizeToFit()
    }
    
    func addTapToView() {
        profileImage.addTarget(self, action: #selector(userTapped), for: .touchUpInside)
        username.addTarget(self, action: #selector(userTapped), for: .touchUpInside)
        let tap = UITapGestureRecognizer(target: self, action: #selector(workoutTapped))
        attachedWorkoutView.addGestureRecognizer(tap)
    }
    
    func setup(rowViewModel: PostProtocol) {
        guard let reply = rowViewModel as? DiscussionReplyPlusWorkout else {return}
        username.setTitle(reply.username, for: .normal)
        textView.text = reply.message
        attachedWorkoutTitle.text = reply.attachedWorkoutTitle
        attachedWorkoutCreator.text = reply.attachedWorkoutCreator
        attachedWorkoutExerciseCount.text = reply.attachedWorkoutExerciseCount?.description
        let replyTime = Date(timeIntervalSince1970: (reply.time!) / 1000)
        timeLabel.text = replyTime.timeAgo()
        ImageAPIService.shared.getProfileImage(for: reply.posterID!) { returnedImage in
            if let image = returnedImage {
                self.profileImage.setImage(image, for: .normal)
            }
        }
    }
    
    static func cellIdentifier() -> String {
        return "AttachedWorkoutReplyCell"
    }
    
    @objc func workoutTapped() {
        delegate.workoutTapped(on: self)
    }
    @objc func userTapped() {
        delegate.userTapped(on: self)
    }
}
