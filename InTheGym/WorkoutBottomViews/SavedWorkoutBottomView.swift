//
//  SavedWorkoutBottomView.swift
//  InTheGym
//
//  Created by Findlay Wood on 10/03/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class SavedWorkoutBottomView: UIView {
    
    var parentView:UIView!
    var newHeightAnchor:NSLayoutConstraint?
    var flashLabel = UILabel()
    var flashView = UIView()
    var bottomViewSetUpClosure: (() -> ())?
    var workout:WorkoutDelegate?
    
    var addButton = UIButton()
    var moreButton = UIButton()
    var lessButton = UIButton()
    var shareToTimelineButton = UIButton()
    var shareToGroupButton = UIButton()
    var mainButtonYAnchor:NSLayoutConstraint?
    
    init(workout: WorkoutDelegate, parent:UIView) {
        self.workout = workout
        self.parentView = parent
        super.init(frame: CGRect.zero)
        setup()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(){
        self.backgroundColor = .white
        self.layer.cornerRadius = 10
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor.black.cgColor
        self.translatesAutoresizingMaskIntoConstraints = false
        parentView.addSubview(self)
        self.bottomAnchor.constraint(equalTo: self.parentView.bottomAnchor).isActive = true
        self.leadingAnchor.constraint(equalTo: self.parentView.leadingAnchor).isActive = true
        self.trailingAnchor.constraint(equalTo: self.parentView.trailingAnchor).isActive = true
        
        newHeightAnchor = self.heightAnchor.constraint(equalTo: self.parentView.heightAnchor, multiplier: 0.15)
        newHeightAnchor?.isActive = true
        
    
        moreButton.setTitle("more", for: .normal)
        moreButton.setTitleColor(Constants.lightColour, for: .normal)
        moreButton.backgroundColor = .clear
        moreButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        moreButton.translatesAutoresizingMaskIntoConstraints = false
        moreButton.addTarget(self, action: #selector(more), for: .touchUpInside)
        
        
        addButton.setTitle("Add to My Workouts", for: .normal)
        addButton.backgroundColor = Constants.darkColour
        addButton.titleLabel?.font = UIFont(name: "Menlo-Bold", size: 25)
        addButton.layer.cornerRadius = 10
        addButton.layer.borderWidth = 2
        addButton.layer.borderColor = UIColor.black.cgColor
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.addTarget(self, action: #selector(addToMyWorkouts), for: .touchUpInside)
        addButton.layer.shadowColor = UIColor.black.cgColor
        addButton.layer.shadowOffset = CGSize(width: 0, height: 0.0)
        addButton.layer.shadowRadius = 6.0
        addButton.layer.shadowOpacity = 1.0
        addButton.layer.masksToBounds = false
        
        //self.addSubview(moreButton)
        self.addSubview(addButton)
        
        //moreButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
        //moreButton.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        
        addButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 25).isActive = true
        addButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -25).isActive = true
        //addButton.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        addButton.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        addButton.heightAnchor.constraint(equalToConstant: 49).isActive = true
        
        mainButtonYAnchor = addButton.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        mainButtonYAnchor?.isActive = true
        

    }
    
    @objc func more(){
        
        flashView.frame = self.parentView.frame
        flashView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5)
        self.parentView.insertSubview(flashView, at: 2)
        flashView.isUserInteractionEnabled = false
        
        newHeightAnchor?.isActive = false
        newHeightAnchor = self.heightAnchor.constraint(equalTo: self.parentView.heightAnchor, multiplier: 0.35)
        newHeightAnchor?.isActive = true
        
        moreButton.removeFromSuperview()
        
        mainButtonYAnchor?.isActive = false
        mainButtonYAnchor = addButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 20)
        mainButtonYAnchor?.isActive = true
        
        lessButton.setTitle("less", for: .normal)
        lessButton.setTitleColor(Constants.darkColour, for: .normal)
        lessButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        lessButton.backgroundColor = .clear
        lessButton.translatesAutoresizingMaskIntoConstraints = false
        lessButton.addTarget(self, action: #selector(less), for: .touchUpInside)
        
        shareToTimelineButton.setTitle("Share To Timeline", for: .normal)
        shareToTimelineButton.backgroundColor = Constants.darkColour
        shareToTimelineButton.titleLabel?.font = UIFont(name: "Menlo-Bold", size: 25)
        shareToTimelineButton.layer.cornerRadius = 10
        shareToTimelineButton.layer.borderWidth = 2
        shareToTimelineButton.layer.borderColor = UIColor.black.cgColor
        shareToTimelineButton.translatesAutoresizingMaskIntoConstraints = false
        shareToTimelineButton.addTarget(self, action: #selector(shareToTimeline), for: .touchUpInside)
        shareToTimelineButton.layer.shadowColor = UIColor.black.cgColor
        shareToTimelineButton.layer.shadowOffset = CGSize(width: 0, height: 0.0)
        shareToTimelineButton.layer.shadowRadius = 6.0
        shareToTimelineButton.layer.shadowOpacity = 1.0
        shareToTimelineButton.layer.masksToBounds = false
        
        shareToGroupButton.setTitle("Share To Group", for: .normal)
        shareToGroupButton.backgroundColor = Constants.darkColour
        shareToGroupButton.titleLabel?.font = UIFont(name: "Menlo-Bold", size: 25)
        shareToGroupButton.layer.cornerRadius = 10
        shareToGroupButton.layer.borderWidth = 2
        shareToGroupButton.layer.borderColor = UIColor.black.cgColor
        shareToGroupButton.translatesAutoresizingMaskIntoConstraints = false
        shareToGroupButton.addTarget(self, action: #selector(shareToGroup), for: .touchUpInside)
        shareToGroupButton.layer.shadowColor = UIColor.black.cgColor
        shareToGroupButton.layer.shadowOffset = CGSize(width: 0, height: 0.0)
        shareToGroupButton.layer.shadowRadius = 6.0
        shareToGroupButton.layer.shadowOpacity = 1.0
        shareToGroupButton.layer.masksToBounds = false
        
        
        self.addSubview(shareToTimelineButton)
        self.addSubview(shareToGroupButton)
        self.addSubview(lessButton)
        
        shareToTimelineButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 25).isActive = true
        shareToTimelineButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -25).isActive = true
        shareToTimelineButton.topAnchor.constraint(equalTo: addButton.bottomAnchor, constant: 20).isActive = true
        shareToTimelineButton.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        shareToTimelineButton.heightAnchor.constraint(equalToConstant: 49).isActive = true
        
        shareToGroupButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 25).isActive = true
        shareToGroupButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -25).isActive = true
        shareToGroupButton.topAnchor.constraint(equalTo: shareToTimelineButton.bottomAnchor, constant: 10).isActive = true
        shareToGroupButton.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        shareToGroupButton.heightAnchor.constraint(equalToConstant: 49).isActive = true
        
        
        lessButton.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        lessButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -20).isActive = true
        lessButton.isHidden = true
        
        UIView.animate(withDuration: 0.3) {
            self.parentView.layoutIfNeeded()
        } completion: { (_) in
            self.lessButton.isHidden = false
        }
    }
    
    @objc func addToMyWorkouts(){
        self.bottomViewSetUpClosure?()
    }
    
    @objc func shareToTimeline(){
        print("share to timeline...")
    }
    
    @objc func shareToGroup(){
        
        newHeightAnchor?.isActive = false
        newHeightAnchor = self.heightAnchor.constraint(equalTo: self.parentView.heightAnchor, multiplier: 0.55)
        newHeightAnchor?.isActive = true
        
        var pc : PresentingView!
        
        UIView.animate(withDuration: 0.3) {
            self.parentView.layoutIfNeeded()
        } completion: { _ in
            pc = PresentingView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
            self.addSubview(pc)
            pc.groupSelectedClosure = { [weak self] (selectedGroup) in
                print("Add the workout \(self?.workout?.title ?? "ERROR") to this group \(selectedGroup.groupTitle ?? "ERROR").")
            }
        }
        


    }
    
    @objc func less(){
        setup()
    }
}
