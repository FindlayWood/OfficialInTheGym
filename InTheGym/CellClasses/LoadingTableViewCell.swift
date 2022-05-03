//
//  LoadingTableViewCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 13/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class LoadingTableViewCell: UITableViewCell {
    
    // MARK: - Subviews
    var activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.hidesWhenStopped = false
        view.style = .large
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Cell Identifier
    static let cellID = "LoadingCellID"
    
    // MARK: - Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
}

// MARK: - Setup UI
private extension LoadingTableViewCell {
    func setupUI() {
        backgroundColor = .clear
        addSubview(activityIndicator)
        activityIndicator.startAnimating()
        constrainUI()
    }
    func constrainUI() {
        NSLayoutConstraint.activate([
                                        activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
                                        activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor),
                                        activityIndicator.topAnchor.constraint(equalTo: topAnchor),
                                        activityIndicator.bottomAnchor.constraint(equalTo: bottomAnchor),
                                        activityIndicator.heightAnchor.constraint(equalToConstant: 60)])
    }
}

