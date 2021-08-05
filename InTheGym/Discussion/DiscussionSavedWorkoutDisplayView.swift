//
//  DiscussionSavedWorkoutDisplayView.swift
//  InTheGym
//
//  Created by Findlay Wood on 18/06/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class DiscussionSavedWorkoutDisplayView: UIView {
    
    var savedWorkoutSelected: ((savedWorkoutDelegate)->())?
    
    var flashView: FlashView! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: #selector(remove))
            flashView.addGestureRecognizer(tap)
        }
    }
    var adapter: SavedWorkoutsAdapter!
    
    lazy var viewModel: SavedWorkoutsViewModel = {
        return SavedWorkoutsViewModel()
    }()
    
    var label: UILabel = {
        let label = UILabel()
        label.text = "Attach a Workout"
        label.font = Constants.font
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var tableView: UITableView = {
        let view = UITableView()
        view.backgroundColor = .clear
        view.tableFooterView = UIView()
        view.register(UINib(nibName: "SavedWorkoutCell", bundle: nil), forCellReuseIdentifier: "SavedWorkoutCell")
        view.register(UINib(nibName: "PrivateSavedWorkoutCell", bundle: nil), forCellReuseIdentifier: "PrivateSavedWorkoutCell")
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }
    required init?(coder: NSCoder) {
        fatalError()
    }
    private func setUpView() {
        adapter = SavedWorkoutsAdapter(delegate: self)
        tableView.delegate = adapter
        tableView.dataSource = adapter
        tableView.emptyDataSetDelegate = adapter
        tableView.emptyDataSetSource = adapter
        tableView.backgroundColor = .clear
        backgroundColor = Constants.lightColour
        layer.cornerRadius = 10
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        clipsToBounds = true
        addSubview(label)
        addSubview(tableView)
        constrainView()
        initViewModel()
    }
    private func constrainView() {
        NSLayoutConstraint.activate([
                                    label.topAnchor.constraint(equalTo: topAnchor, constant: 5),
                                    label.centerXAnchor.constraint(equalTo: centerXAnchor),
            
                                    tableView.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 5),
                                    tableView.leadingAnchor.constraint(equalTo: leadingAnchor,constant: 5),
                                    tableView.trailingAnchor.constraint(equalTo: trailingAnchor,constant: -5),
                                    tableView.bottomAnchor.constraint(equalTo: bottomAnchor)
        
        ])
    }
    @objc func remove() {
        let hiddenFrame = CGRect(x: 0, y: Constants.screenSize.height, width: frame.width, height: frame.height)
        UIView.animate(withDuration: 0.3) {
            self.frame = hiddenFrame
            self.flashView.alpha = 0
        } completion: { _ in
            self.flashView.removeFromSuperview()
            self.removeFromSuperview()
        }

    }
}

extension DiscussionSavedWorkoutDisplayView {
    func initViewModel() {
        viewModel.reloadTableViewClosure = { [weak self] in
            guard let self = self else {return}
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        viewModel.fetchData()
    }
}

extension DiscussionSavedWorkoutDisplayView: SavedWorkoutsProtocol {
    func getData(at: IndexPath) -> savedWorkoutDelegate {
        viewModel.getData(at: at)
    }
    
    func itemSelected(at: IndexPath) {
        let selectedWorkout = viewModel.getData(at: at)
        print(selectedWorkout.title!)
        remove()
        savedWorkoutSelected?(selectedWorkout)
    }
    
    func retreiveNumberOfItems() -> Int {
        return 1
    }
    
    func retreiveNumberOfSections() -> Int {
        return viewModel.numberOfItems
    }
    
    
}
 
