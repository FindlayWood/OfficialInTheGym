//
//  CreateEMOMView.swift
//  InTheGym
//
//  Created by Findlay Wood on 15/09/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class CreateEMOMView: UIView {
    
    // MARK: - Subviews
    var timeView: UIView = {
        let view = UIView()
        view.backgroundColor = Constants.offWhiteColour
        view.layer.cornerRadius = 10
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 0.0)
        view.layer.shadowRadius = 6.0
        view.layer.shadowOpacity = 1.0
        view.isUserInteractionEnabled = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var timeLabel: UILabel = {
        let label = UILabel()
        label.text = "Time"
        label.font = Constants.font
        label.textColor = Constants.darkColour
        label.isUserInteractionEnabled = false
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var timeNumberLabel: UILabel = {
       let label = UILabel()
        label.font = Constants.font
        label.textColor = Constants.darkColour
        label.isUserInteractionEnabled = false
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var timeMessage: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .darkGray
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.text = StaticMessages.emomTimeMessage
        label.isUserInteractionEnabled = false
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var exerciseLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.font
        label.textColor = .black
        label.textAlignment = .center
        label.text = "Exercises"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var tableview: UITableView = {
        let tv = UITableView()
        tv.tableFooterView = UIView()
        tv.backgroundColor = .white
        tv.register(NewExerciseCell.self, forCellReuseIdentifier: NewExerciseCell.cellID)
        tv.register(AMRAPCell.self, forCellReuseIdentifier: AMRAPCell.cellID)
        if #available(iOS 15.0, *) { tv.sectionHeaderTopPadding = 0 }
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
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
private extension CreateEMOMView {
    
    private func setupUI() {
        backgroundColor = .secondarySystemBackground
        addSubview(timeView)
        timeView.addSubview(timeLabel)
        timeView.addSubview(timeNumberLabel)
        timeView.addSubview(timeMessage)
        addSubview(exerciseLabel)
        addSubview(tableview)
        constrainUI()
    }
    
    
    func constrainUI() {
        NSLayoutConstraint.activate([timeLabel.topAnchor.constraint(equalTo: timeView.topAnchor, constant: 10),
                                     timeLabel.leadingAnchor.constraint(equalTo: timeView.leadingAnchor, constant: 10),
                                     
                                     timeNumberLabel.topAnchor.constraint(equalTo: timeView.topAnchor, constant: 10),
                                     timeNumberLabel.trailingAnchor.constraint(equalTo: timeView.trailingAnchor, constant: -10),
                                     
                                     timeMessage.leadingAnchor.constraint(equalTo: timeView.leadingAnchor, constant: 10),
                                     timeMessage.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 5),
                                     timeMessage.trailingAnchor.constraint(equalTo: timeView.trailingAnchor, constant: -10),
                                     timeMessage.bottomAnchor.constraint(equalTo: timeView.bottomAnchor, constant: -10),
                                        
                                     timeView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 10),
                                     timeView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
                                     timeView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
                                     
                                     exerciseLabel.topAnchor.constraint(equalTo: timeView.bottomAnchor, constant: 15),
                                     exerciseLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
                                        
                                     tableview.topAnchor.constraint(equalTo: exerciseLabel.bottomAnchor, constant: 0),
                                     tableview.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
                                     tableview.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
                                     tableview.bottomAnchor.constraint(equalTo: bottomAnchor)])
    }
}

// MARK: - Public configuration
extension CreateEMOMView {
    public func updateTime(with newTime: Int) {
        timeNumberLabel.text = newTime.description + " mins"
    }
}
