//
//  DisplayCircuitView.swift
//  InTheGym
//
//  Created by Findlay Wood on 25/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class DisplayCircuitView: UIView {
    // MARK: - Properties
    
    // MARK: - Subviews
    var tableview: UITableView = {
        let view = UITableView()
        view.tableFooterView = UIView()
        if #available(iOS 15.0, *) { view.sectionHeaderTopPadding = 0 }
        view.register(UINib(nibName: "DisplayCircuitExerciseTableViewCell", bundle: nil), forCellReuseIdentifier: "DisplayCircuitExerciseTableViewCell")
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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
private extension DisplayCircuitView {
    func setupUI() {
        backgroundColor = .lightColour
        addSubview(tableview)
        configureUI()
    }
    
    func configureUI() {
        NSLayoutConstraint.activate([
            tableview.topAnchor.constraint(equalTo: topAnchor),
            tableview.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            tableview.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
            tableview.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
