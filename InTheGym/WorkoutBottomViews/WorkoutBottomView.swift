//
//  WorkoutBottomView.swift
//  InTheGym
//
//  Created by Findlay Wood on 25/05/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

enum bottomViewState {
    case normal
    case expanded
}

class WorkoutBottomView: UIView {
    
    private let screen = UIScreen.main.bounds
    private lazy var normalHeight = Constants.screenSize.height * 0.15
    private lazy var expandedHeight = Constants.screenSize.height * 0.6
    private lazy var normalFrame = CGRect(x: 0, y: screen.height - normalHeight, width: screen.width, height: maxHeight)
    private lazy var expandedFrame = CGRect(x: 0, y: screen.height - expandedHeight, width: screen.width, height: maxHeight)
    private lazy var originPoint = normalFrame.origin
    private lazy var expandedOriginPoint = expandedFrame.origin
    private var bottomViewCurrentState: bottomViewState = .normal
    
    private let maxHeight = Constants.screenSize.height * 0.8
    private let minHeight = Constants.screenSize.height * 0.1
    
    private let buttonHeight = Constants.screenSize.height * 0.05
    
    var flashview: FlashView! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: #selector(flashViewTapped))
            flashview.addGestureRecognizer(tap)
        }
    }
    
    private let tableContents = ["View Creator Profile", "View Workout Stats"]
    
    lazy var bottomView: UIView = {
        let view = UIView(frame: normalFrame)
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.clipsToBounds = true
        view.isUserInteractionEnabled = true
        return view
    }()
    
    var scrollIndicatorView: UIView = {
       let view = UIView()
        view.backgroundColor = .darkGray
        view.layer.cornerRadius = 3
        view.clipsToBounds = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var mainButton: UIButton = {
       let button = UIButton()
        button.backgroundColor = Constants.darkColour
        button.setTitle("Save Workout", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont(name: "Menlo-Bold", size: 25)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.3
        button.layer.cornerRadius = buttonHeight / 2
        button.titleLabel?.textAlignment = .center
        button.isUserInteractionEnabled = true
        button.layer.shadowColor = UIColor.darkGray.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 0.0)
        button.layer.shadowRadius = 6.0
        button.layer.shadowOpacity = 1.0
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var tableview: UITableView = {
       let tv = UITableView()
        tv.backgroundColor = .white
        tv.tableFooterView = UIView()
        tv.bounces = false
        tv.alwaysBounceVertical = false
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
    
    
    private func setUpView() {
        layer.cornerRadius = 20
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        clipsToBounds = true
        backgroundColor = .white
        addSubview(mainButton)
        addSubview(tableview)
        addSubview(scrollIndicatorView)
        tableview.dataSource = self
        tableview.delegate = self
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panGestureAction(_:)))
        addGestureRecognizer(pan)
        constrain()
    }
    
    private func constrain() {
        NSLayoutConstraint.activate([mainButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 25),
                                     mainButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -25),
                                     mainButton.topAnchor.constraint(equalTo: topAnchor, constant: Constants.screenSize.height * 0.04),
                                     mainButton.heightAnchor.constraint(equalToConstant: Constants.screenSize.height * 0.05),
                                     
                                     scrollIndicatorView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
                                     scrollIndicatorView.centerXAnchor.constraint(equalTo: centerXAnchor),
                                     scrollIndicatorView.heightAnchor.constraint(equalToConstant: 6),
                                     scrollIndicatorView.widthAnchor.constraint(equalToConstant: Constants.screenSize.width * 0.2),
        
                                     tableview.topAnchor.constraint(equalTo: topAnchor, constant: normalHeight),
                                     tableview.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
                                     tableview.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
                                     tableview.heightAnchor.constraint(equalToConstant: expandedHeight - normalHeight)])
    }
    
    @objc func panGestureAction(_ sender: UIPanGestureRecognizer) {

        let translation = sender.translation(in: self)

        var currentYorigin: CGFloat!


        switch bottomViewCurrentState {
        case .normal:
            guard originPoint.y + translation.y < Constants.screenSize.height - minHeight  else {
                snapToState(.normal)
                return
            }
            guard originPoint.y + translation.y > Constants.screenSize.height - maxHeight else {
                snapToState(.expanded)
                return
            }

            currentYorigin = originPoint.y
            frame = CGRect(x: 0, y: originPoint.y + translation.y, width: screen.width, height: screen.height)
        case .expanded:
            guard expandedOriginPoint.y + translation.y < Constants.screenSize.height - minHeight else {
                snapToState(.normal)
                return
            }
            guard expandedOriginPoint.y + translation.y > Constants.screenSize.height - maxHeight else {
                snapToState(.expanded)
                return
            }
            currentYorigin = expandedOriginPoint.y
            frame = CGRect(x: 0, y: expandedOriginPoint.y + translation.y, width: screen.width, height: screen.height)
        }



        switch sender.state {
        case .ended:
            let difference = (expandedHeight - normalHeight) / 2
            if currentYorigin + translation.y < Constants.screenSize.height - normalHeight - difference {
                snapToState(.expanded)
            } else {
                snapToState(.normal)
            }
        default:
            break
        }

    }

    private func snapToState(_ state: bottomViewState) {
        switch state{
        case .normal:
            bottomViewCurrentState = .normal
            UIView.animate(withDuration: 0.3) {
                self.frame = self.normalFrame
                self.flashview.alpha = 0.2
            } completion: { _ in
                self.flashview.isUserInteractionEnabled = false
            }
        case .expanded:
            bottomViewCurrentState = .expanded
            UIView.animate(withDuration: 0.3) {
                self.frame = self.expandedFrame
                self.flashview.alpha = 0.7
            } completion: { _ in
                self.flashview.isUserInteractionEnabled = true
            }
        }
    }
    
    @objc private func flashViewTapped() {
        if bottomViewCurrentState == .expanded {
            snapToState(.normal)
        }
    }
    
}

extension WorkoutBottomView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableContents.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = tableContents[indexPath.row]
        cell.textLabel?.textColor = Constants.darkColour
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .none
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(tableContents[indexPath.row])
    }
}
