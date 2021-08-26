//
//  GroupAddPlayersAdapter.swift
//  InTheGym
//
//  Created by Findlay Wood on 09/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class GroupAddPlayersAdapter: NSObject {
    var delegate: GroupAddPlayersProtocol!
    init(delegate: GroupAddPlayersProtocol) {
        self.delegate = delegate
    }
}

extension GroupAddPlayersAdapter: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return delegate.numberOfPlayers()
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UserTableViewCell.cellID, for: indexPath) as! UserTableViewCell
        let userData = delegate.getPlayerData(at: indexPath)
        cell.configureCell(with: userData)
        if delegate.checkIfPlayerSelected(delegate.getPlayerData(at: indexPath)) {
            cell.accessoryType = .checkmark
            cell.selected()
        } else {
            cell.accessoryType = .none
            cell.notSelected()
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate.playerSelected(at: indexPath)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
