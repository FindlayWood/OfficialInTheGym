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
        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate.playerSelected(at: indexPath)
    }
}
