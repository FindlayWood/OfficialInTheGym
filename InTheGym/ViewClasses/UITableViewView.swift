//
//  TableViewView.swift
//  InTheGym
//
//  Created by Findlay Wood on 15/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

/// This class is a subclass of  UIView and creates a tableview that covers the full view
class UITableViewView: UIView {
    
    // MARK: - Subview
    /// only subview is a tableview that covers the full view
    var tableview: UITableView = {
        let view = UITableView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.style = .whiteLarge
        view.hidesWhenStopped = true
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

// MARK: - Setup UI
private extension UITableViewView {
    func setupUI() {
        addSubview(activityIndicator)
        addSubview(tableview)
        constrainUI()
    }
    func constrainUI() {
        NSLayoutConstraint.activate([
                                        activityIndicator.topAnchor.constraint(equalTo: topAnchor),
                                        activityIndicator.leadingAnchor.constraint(equalTo: leadingAnchor),
                                        activityIndicator.trailingAnchor.constraint(equalTo: trailingAnchor),
                                        activityIndicator.bottomAnchor.constraint(equalTo: bottomAnchor),
                                        
                                     tableview.topAnchor.constraint(equalTo: topAnchor),
                                     tableview.leadingAnchor.constraint(equalTo: leadingAnchor),
                                     tableview.trailingAnchor.constraint(equalTo: trailingAnchor),
                                     tableview.bottomAnchor.constraint(equalTo: bottomAnchor)])
    }
}
