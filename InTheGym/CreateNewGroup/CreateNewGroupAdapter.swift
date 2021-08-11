//
//  CreateNewGroupAdapter.swift
//  InTheGym
//
//  Created by Findlay Wood on 09/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class CreateNewGroupAdapter: NSObject {
    var delegate: CreateNewGroupProtocol
    init(delegate: CreateNewGroupProtocol) {
        self.delegate = delegate
    }
}

extension CreateNewGroupAdapter: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return delegate.numberOfItems()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == delegate.numberOfItems() - 1 {
            let cell = UITableViewCell()
            cell.textLabel?.text = "Add Players"
            cell.textLabel?.font = UIFont(name: "Menlo-Bold", size: 20)
            cell.textLabel?.textColor = .white
            cell.layer.cornerRadius = 8
            cell.selectionStyle = .none
            cell.backgroundColor = Constants.darkColour
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: UserTableViewCell.cellID, for: indexPath) as! UserTableViewCell
            cell.configureCell(with: delegate.getData(at: indexPath))
            return cell
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == delegate.numberOfItems() - 1 {
            delegate.addPlayers()
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        } else {
            return 10
        }
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
}
