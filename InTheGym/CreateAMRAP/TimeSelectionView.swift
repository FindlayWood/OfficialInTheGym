//
//  TimeSelectionView.swift
//  InTheGym
//
//  Created by Findlay Wood on 05/06/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class TimeSelectionView: UIView {
    
    var delegate: CreateAMRAPProtocol!
    var flashview: FlashView! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: #selector(remove))
            flashview.addGestureRecognizer(tap)
        }
    }
    
    var tableview: UITableView = {
        let tv = UITableView()
        tv.tableFooterView = UIView()
        tv.backgroundColor = Constants.offWhiteColour
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    var timeLabel: UILabel = {
        let label = UILabel()
        label.text = "Choose Time"
        label.font = Constants.font
        label.textColor = Constants.darkColour
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func setup() {
        backgroundColor = Constants.offWhiteColour
        layer.cornerRadius = 10
        clipsToBounds = true
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        addSubview(timeLabel)
        addSubview(tableview)
        tableview.delegate = self
        tableview.dataSource = self
        constrain()
    }
    
    
    private func constrain() {
        NSLayoutConstraint.activate([timeLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
                                     timeLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
        
                                     tableview.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 10),
                                     tableview.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
                                     tableview.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
                                     tableview.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20)])
    }
    
    @objc private func remove() {
        let hiddenFrame = CGRect(x: 0, y: Constants.screenSize.height, width: frame.width, height: frame.height)
        UIView.animate(withDuration: 0.3) {
            self.frame = hiddenFrame
            self.flashview.alpha = 0
        } completion: { _ in
            self.flashview.removeFromSuperview()
            self.removeFromSuperview()
        }
    }
}

extension TimeSelectionView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 30
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = "\(indexPath.section + 1) minutes"
        cell.textLabel?.font = Constants.font
        cell.layer.cornerRadius = 10
        if indexPath.section + 1 == delegate.getTime() {
            cell.backgroundColor = Constants.darkColour
            cell.textLabel?.textColor = .white
        } else {
            cell.backgroundColor = .white
            cell.textLabel?.textColor = Constants.darkColour
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate.timeSelected(newTime: indexPath.section + 1)
        tableview.reloadData()
        remove()
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
}
