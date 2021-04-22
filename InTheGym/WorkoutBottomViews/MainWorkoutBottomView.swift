//
//  MainWorkoutBottomView.swift
//  InTheGym
//
//  Created by Findlay Wood on 10/03/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class MainWorkoutBottomView:UIView{
    
    var parentView:UIView!
    var newHeightAnchor:NSLayoutConstraint?
    var flashLabel = UILabel()
    var flashView = UIView()
    var bottomViewSetUpClosure: (() -> ())?
    var workout:WorkoutDelegate?

    init(workout: WorkoutDelegate, parent:UIView) {
        self.workout = workout
        self.parentView = parent
        super.init(frame: CGRect.zero)
        setup()
        flashView.frame = self.parentView.frame
        flashView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5)
        self.parentView.insertSubview(flashView, at: 2)
        flashView.isUserInteractionEnabled = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func setup(){
        for view in self.subviews{
            view.removeFromSuperview()
        }
        self.removeFromSuperview()
        newHeightAnchor?.isActive = false
        
        
        self.backgroundColor = .white
        self.layer.cornerRadius = 10
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor.black.cgColor
        self.translatesAutoresizingMaskIntoConstraints = false
        parentView.addSubview(self)
        self.bottomAnchor.constraint(equalTo: self.parentView.bottomAnchor).isActive = true
        self.leadingAnchor.constraint(equalTo: self.parentView.leadingAnchor).isActive = true
        self.trailingAnchor.constraint(equalTo: self.parentView.trailingAnchor).isActive = true
        
        newHeightAnchor = self.heightAnchor.constraint(equalTo: self.parentView.heightAnchor, multiplier: 0.25)
        newHeightAnchor?.isActive = true
        
        let beginButton = UIButton()
        beginButton.setTitle("Begin Workout", for: .normal)
        beginButton.backgroundColor = Constants.darkColour
        beginButton.titleLabel?.font = UIFont(name: "Menlo-Bold", size: 31)
        beginButton.layer.cornerRadius = 10
        beginButton.layer.borderWidth = 2
        beginButton.layer.borderColor = UIColor.black.cgColor
        beginButton.translatesAutoresizingMaskIntoConstraints = false
        beginButton.addTarget(self, action: #selector(setViewToStage2), for: .touchUpInside)
        // add shadows to the add button
        beginButton.layer.shadowColor = UIColor.black.cgColor
        beginButton.layer.shadowOffset = CGSize(width: 0, height: 0.0)
        beginButton.layer.shadowRadius = 6.0
        beginButton.layer.shadowOpacity = 1.0
        beginButton.layer.masksToBounds = false
        
        let label = UILabel()
        label.text = "Timer will begin on button click."
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textColor = .lightGray
        label.textAlignment = .center
        
        let label2 = UILabel()
        label2.text = "Scroll to view exercises."
        label2.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label2.textColor = .lightGray
        label2.textAlignment = .center
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.spacing = 10
        
        stackView.addArrangedSubview(beginButton)
        stackView.addArrangedSubview(label)
        stackView.addArrangedSubview(label2)
        
        self.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        stackView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        beginButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 25).isActive = true
        beginButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -25).isActive = true
        beginButton.heightAnchor.constraint(equalToConstant: 49).isActive = true
    }
    
    @objc func setViewToStage2(){
        
        for view in self.subviews{
            view.removeFromSuperview()
        }
        
        let label = UILabel()
        label.text = "ARE YOU READY TO BEGIN?"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .black
        label.textAlignment = .center
        
        let button = UIButton()
        button.setTitle("CONTINUE", for: .normal)
        button.backgroundColor = Constants.darkColour
        button.titleLabel?.font = UIFont(name: "Menlo-Bold", size: 31)
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.black.cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 49).isActive = true
        button.addTarget(self, action: #selector(workoutHasBegun), for: .touchUpInside)
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 0.0)
        button.layer.shadowRadius = 6.0
        button.layer.shadowOpacity = 1.0
        button.layer.masksToBounds = false
        
        
        let noticeLabel = UILabel()
        noticeLabel.text = "The timer will begin and can't be stopped."
        noticeLabel.font = UIFont.boldSystemFont(ofSize: 12)
        noticeLabel.textColor = .lightGray
        noticeLabel.textAlignment = .center
        
        let noticeLabel2 = UILabel()
        noticeLabel2.text = "Press CONTINUE to begin workout."
        noticeLabel2.font = UIFont.boldSystemFont(ofSize: 12)
        noticeLabel2.textColor = .lightGray
        noticeLabel2.textAlignment = .center
        
        let cancelButton = UIButton()
        cancelButton.setTitle("cancel", for: .normal)
        cancelButton.backgroundColor = UIColor.clear
        cancelButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        cancelButton.setTitleColor(UIColor.red, for: .normal)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.addTarget(self, action: #selector(setup), for: .touchUpInside)
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.spacing = 10.0
        
        stackView.addArrangedSubview(label)
        stackView.addArrangedSubview(button)
        stackView.addArrangedSubview(noticeLabel)
        stackView.addArrangedSubview(noticeLabel2)
        self.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: self.topAnchor, constant: 20).isActive = true
        stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10).isActive = true
        stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10).isActive = true
        button.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: 15).isActive = true
        button.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: -15).isActive = true
        self.addSubview(cancelButton)
        cancelButton.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 30).isActive = true
        cancelButton.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        //cancelButton.leadingAnchor.constraint(equalTo: self.beginView.leadingAnchor, constant: 35).isActive = true
        //cancelButton.trailingAnchor.constraint(equalTo: self.beginView.trailingAnchor, constant: -35).isActive = true
        
        stackView.isHidden = true
        cancelButton.isHidden = true
        
        newHeightAnchor?.isActive = false
        newHeightAnchor = self.heightAnchor.constraint(equalTo: self.parentView.heightAnchor, multiplier: 0.35)
        newHeightAnchor?.isActive = true
        
        let notificationFeedbackGenerator = UINotificationFeedbackGenerator()
        notificationFeedbackGenerator.prepare()
        
        UIView.animate(withDuration: 0.5) {
            self.parentView.layoutIfNeeded()
        } completion: { (_) in
            stackView.isHidden = false
            cancelButton.isHidden = false
            notificationFeedbackGenerator.notificationOccurred(.warning)
        }
        
    }
    
    @objc func workoutHasBegun(){
        
        for view in self.subviews{
            view.removeFromSuperview()
        }
    
        // haptic feedback : begin workout
        let notificationFeedbackGenerator = UINotificationFeedbackGenerator()
        notificationFeedbackGenerator.prepare()
        
//        self.workoutBegun = true
//        self.startTime = Date.timeIntervalSinceReferenceDate
//        self.DBRef.child("\(self.workoutID)").updateChildValues(["startTime" : self.startTime!])
        
        newHeightAnchor?.isActive = false
        newHeightAnchor = self.heightAnchor.constraint(equalTo: self.parentView.heightAnchor)
        newHeightAnchor?.isActive = true
        
        flashLabel.text = workout?.title
        flashLabel.textColor = .black
        flashLabel.font = UIFont(name: "Menlo-Bold", size: 25)
        flashLabel.textAlignment = .center
        flashLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(flashLabel)
        flashLabel.centerXAnchor.constraint(equalTo: parentView.centerXAnchor).isActive = true
        flashLabel.centerYAnchor.constraint(equalTo: parentView.centerYAnchor).isActive = true
        flashLabel.isHidden = true

        
        
        UIView.animate(withDuration: 0.5) {
            self.parentView.layoutIfNeeded()
        } completion: { (_) in
            self.flashLabel.isHidden = false
            self.flashView.removeFromSuperview()
            notificationFeedbackGenerator.notificationOccurred(.success)
//            let indexToScroll = IndexPath.init(row: 0, section: 0)
//            self.tableview.scrollToRow(at: indexToScroll, at: .top, animated: true)
            UIView.animate(withDuration: 0.2, delay: 1.0) {
                self.backgroundColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)
            } completion: { (_) in
                self.removeFromSuperview()
                self.flashLabel.removeFromSuperview()
                self.bottomViewSetUpClosure?()
            }
        }
   }
    
    
}
