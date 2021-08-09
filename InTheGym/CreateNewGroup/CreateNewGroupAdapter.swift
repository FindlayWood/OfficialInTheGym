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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return delegate.numberOfItems()
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == delegate.numberOfItems() {
            delegate.addPlayers()
        }
    }
}
