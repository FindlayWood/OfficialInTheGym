//
//  GroupAddPlayersView.swift
//  InTheGym
//
//  Created by Findlay Wood on 09/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class GroupAddPlayersView: UIView {
    
    // MARK: - Subviews
    var tableview: UITableView = {
        let view = UITableView()
        view.tableFooterView = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var loadingIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.color = Constants.darkColour
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpUI()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUpUI()
    }
}

//MARK: - SetUp
private extension GroupAddPlayersView {
    func setUpUI() {
        backgroundColor = .white
        addSubview(loadingIndicator)
        addSubview(tableview)
        constrainUI()
    }
    
    func constrainUI() {
        NSLayoutConstraint.activate([loadingIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
                                     loadingIndicator.centerYAnchor.constraint(equalTo: centerYAnchor),
        
                                     tableview.topAnchor.constraint(equalTo: topAnchor),
                                     tableview.leadingAnchor.constraint(equalTo: leadingAnchor),
                                     tableview.trailingAnchor.constraint(equalTo: trailingAnchor),
                                     tableview.bottomAnchor.constraint(equalTo: bottomAnchor)])
    }
}
