//
//  DisplayExerciseStatsView.swift
//  InTheGym
//
//  Created by Findlay Wood on 28/06/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class DisplayExerciseStatsView: UIView {
    
    var activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.color = Constants.darkColour
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    //let searchController = UISearchController(searchResultsController: nil)
    
    var searchController: UISearchController = {
        let view = UISearchController(searchResultsController: nil)
        view.obscuresBackgroundDuringPresentation = false
        return view
    }()
    
    var tableview: UITableView = {
        let view = UITableView()
        view.register(ExerciseStatsTitleCell.self, forCellReuseIdentifier: ExerciseStatsTitleCell.cellID)
        view.register(ExerciseStatsSectionCell.self, forCellReuseIdentifier: "sectionCell")
        view.backgroundColor = .white
        view.tableFooterView = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var isSearchBarEmpty: Bool {
      return searchController.searchBar.text?.isEmpty ?? true
    }
    var isFiltering: Bool {
      return searchController.isActive && !isSearchBarEmpty
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func setUpView() {
        backgroundColor = .white
        tableview.tableHeaderView = searchController.searchBar
        addSubview(tableview)
        addSubview(activityIndicator)
        constrainView()
    }
    
    func constrainView() {
        NSLayoutConstraint.activate([activityIndicator.leadingAnchor.constraint(equalTo: leadingAnchor),
                                     activityIndicator.topAnchor.constraint(equalTo: topAnchor),
                                     activityIndicator.trailingAnchor.constraint(equalTo: trailingAnchor),
                                     activityIndicator.bottomAnchor.constraint(equalTo: bottomAnchor),
        
                                     tableview.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
                                     tableview.topAnchor.constraint(equalTo: topAnchor),
                                     tableview.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
                                     tableview.bottomAnchor.constraint(equalTo: bottomAnchor)])
    }
}
