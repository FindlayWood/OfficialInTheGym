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
    var bottomViewSetUpClosure: (() -> ())?
    var viewProfileTapped: (() -> ())?
    var workout:WorkoutDelegate?
    
    var addButton : UIButton = {
        let addButton = UIButton()
        addButton.setTitle("Add to My Workouts", for: .normal)
        addButton.backgroundColor = Constants.darkColour
        addButton.titleLabel?.font = UIFont(name: "Menlo-Bold", size: 25)
        addButton.layer.cornerRadius = 24.5
        //addButton.layer.borderWidth = 2
        //addButton.layer.borderColor = UIColor.black.cgColor
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.addTarget(self, action: #selector(addToMyWorkouts), for: .touchUpInside)
        addButton.layer.shadowColor = UIColor.darkGray.cgColor
        addButton.layer.shadowOffset = CGSize(width: 0, height: 0.0)
        addButton.layer.shadowRadius = 6.0
        addButton.layer.shadowOpacity = 1.0
        addButton.layer.masksToBounds = false
        return addButton
    }()
    
    var moreButton : UIButton = {
        let moreButton = UIButton()
        moreButton.setTitle("more", for: .normal)
        moreButton.setTitleColor(Constants.lightColour, for: .normal)
        moreButton.backgroundColor = .clear
        moreButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        moreButton.translatesAutoresizingMaskIntoConstraints = false
        moreButton.addTarget(self, action: #selector(more), for: .touchUpInside)
        return moreButton
    }()

    var tableviewTopAnchor: NSLayoutConstraint?
    
    var scrollIndicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = Constants.offWhiteColour
        view.layer.cornerRadius = 5
        view.clipsToBounds = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var optionLabel: UILabel = {
        let ol = UILabel()
        ol.text = "Options"
        ol.textColor = .black
        ol.font = UIFont.boldSystemFont(ofSize: 20)
        ol.translatesAutoresizingMaskIntoConstraints = false
        ol.backgroundColor = .clear
        return ol
    }()
    
    lazy var flashView: UIView = {
        let flashView = UIView()
        flashView.frame = parentView.frame
        flashView.backgroundColor = .black
        flashView.alpha = 0.2
        flashView.isUserInteractionEnabled = false
        return flashView
    }()
    
    var tableview: UITableView = {
        let tv = UITableView()
        tv.tableFooterView = UIView()
        tv.backgroundColor = .white
        tv.isScrollEnabled = false
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    init(workout: WorkoutDelegate, parent:UIView) {
        self.workout = workout
        self.parentView = parent
        super.init(frame: CGRect.zero)
        tableview.delegate = self
        tableview.dataSource = self
        setup()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(){
        self.backgroundColor = .white
        self.layer.cornerRadius = 20
        self.translatesAutoresizingMaskIntoConstraints = false
        parentView.addSubview(self)
        self.bottomAnchor.constraint(equalTo: self.parentView.bottomAnchor).isActive = true
        self.leadingAnchor.constraint(equalTo: self.parentView.leadingAnchor).isActive = true
        self.trailingAnchor.constraint(equalTo: self.parentView.trailingAnchor).isActive = true
        
        let swipeUpGesture = UISwipeGestureRecognizer(target: self, action: #selector(more))
        swipeUpGesture.direction = .up
        self.addGestureRecognizer(swipeUpGesture)
        
        newHeightAnchor = self.heightAnchor.constraint(equalTo: self.parentView.heightAnchor, multiplier: 0.15)
        newHeightAnchor?.isActive = true
        
        
        self.addSubview(addButton)
        self.addSubview(scrollIndicatorView)
        self.addSubview(optionLabel)
        self.addSubview(tableview)
        parentView.insertSubview(flashView, at: 2)
        
        optionLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
        optionLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        
        
        scrollIndicatorView.bottomAnchor.constraint(equalTo: self.topAnchor, constant: -5).isActive = true
        scrollIndicatorView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        scrollIndicatorView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        scrollIndicatorView.heightAnchor.constraint(equalToConstant: 10).isActive = true
        
        
        addButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 25).isActive = true
        addButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -25).isActive = true
        addButton.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        addButton.heightAnchor.constraint(equalToConstant: 49).isActive = true
        addButton.topAnchor.constraint(equalTo: optionLabel.bottomAnchor, constant: 10).isActive = true
        
        
        tableviewTopAnchor = tableview.topAnchor.constraint(equalTo: self.bottomAnchor)
        tableviewTopAnchor?.isActive = true
        tableview.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        tableview.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        tableview.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        

    }
    
    @objc func more(){
        
        //flashView.alpha = 0.6
        flashView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(less))
        flashView.addGestureRecognizer(tap)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(less))
        swipeDown.direction = .down
        flashView.addGestureRecognizer(swipeDown)
        self.addGestureRecognizer(swipeDown)
        
        newHeightAnchor?.isActive = false
        newHeightAnchor = self.heightAnchor.constraint(equalTo: self.parentView.heightAnchor, multiplier: 0.35)
        newHeightAnchor?.isActive = true
        
        
        tableviewTopAnchor?.isActive = false
        tableviewTopAnchor = tableview.topAnchor.constraint(equalTo: addButton.bottomAnchor, constant: 20)
        tableviewTopAnchor?.isActive = true


        UIView.animate(withDuration: 0.3) {
            self.parentView.layoutIfNeeded()
            self.flashView.alpha = 0.6
        }
    }
    
    @objc func addToMyWorkouts(){
        self.bottomViewSetUpClosure?()
    }
        
    
    @objc func less(){
        //flashView.alpha = 0.2
        flashView.isUserInteractionEnabled = false
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(more))
        swipeUp.direction = .up
        self.addGestureRecognizer(swipeUp)
        
        newHeightAnchor?.isActive = false
        newHeightAnchor = self.heightAnchor.constraint(equalTo: self.parentView.heightAnchor, multiplier: 0.15)
        newHeightAnchor?.isActive = true
        
        
        tableviewTopAnchor?.isActive = false
        tableviewTopAnchor = tableview.topAnchor.constraint(equalTo: self.bottomAnchor)
        tableviewTopAnchor?.isActive = true


        UIView.animate(withDuration: 0.3) {
            self.flashView.alpha = 0.2
            self.parentView.layoutIfNeeded()
        }
    }
}

extension SavedWorkoutBottomView: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = "View Creator Profile"
        cell.textLabel?.textColor = Constants.darkColour
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            self.viewProfileTapped?()
        }
    }
}
