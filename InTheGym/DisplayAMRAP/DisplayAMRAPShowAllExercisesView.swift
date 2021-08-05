//
//  DisplayAMRAPShowAllExercisesView.swift
//  InTheGym
//
//  Created by Findlay Wood on 03/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class DisplayAMRAPShowAllExercisesView: UIView {
    
    var tableview: UITableView = {
        let view = UITableView()
        view.tableFooterView = UIView()
        view.register(AMRAPCell.self, forCellReuseIdentifier: "cell")
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var closeButton: UIButton = {
        let button = UIButton()
        button.setTitle("dismiss", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 15)
        button.setTitleColor(Constants.darkColour, for: .normal)
        button.addTarget(self, action: #selector(dismiss), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }
    required init?(coder: NSCoder) {
        fatalError()
    }
    private func setUpView() {
        backgroundColor = .white
        layer.cornerRadius = 10
        clipsToBounds = true
        addSubview(closeButton)
        addSubview(tableview)
        constrainView()
    }
    private func constrainView() {
        NSLayoutConstraint.activate([closeButton.topAnchor.constraint(equalTo: topAnchor, constant: 5),
                                     closeButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
                                     
                                     tableview.topAnchor.constraint(equalTo: closeButton.bottomAnchor),
                                     tableview.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
                                     tableview.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
                                     tableview.bottomAnchor.constraint(equalTo: bottomAnchor)])
    }
    @objc private func dismiss() {
        removeFromSuperview()
    }
}
