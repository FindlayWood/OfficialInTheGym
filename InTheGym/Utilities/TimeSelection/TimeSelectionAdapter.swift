//
//  TimeSelectionAdapter.swift
//  InTheGym
//
//  Created by Findlay Wood on 21/09/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class TimeSelectionAdapter: NSObject {
    var delegate: TimeSelectionProtocol
    init(delegate: TimeSelectionProtocol) {
        self.delegate = delegate
    }
}

extension TimeSelectionAdapter: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 30
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = "\(indexPath.section + 1) minutes"
        cell.textLabel?.font = Constants.font
        cell.layer.cornerRadius = 10
        if indexPath.section + 1 == delegate.getCurrentTime() {
            cell.backgroundColor = Constants.darkColour
            cell.textLabel?.textColor = .white
        } else {
            cell.backgroundColor = .white
            cell.textLabel?.textColor = Constants.darkColour
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate.newTimeSelected(indexPath.section + 1)
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
}
