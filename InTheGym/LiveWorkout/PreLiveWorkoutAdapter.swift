//
//  PreLiveWorkoutAdapter.swift
//  InTheGym
//
//  Created by Findlay Wood on 31/07/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class PreLiveWorkoutAdapter: NSObject {
    var delegate: PreLiveWorkoutProtocol
    init(delegate: PreLiveWorkoutProtocol) {
        self.delegate = delegate
    }
}

extension PreLiveWorkoutAdapter: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return delegate.numberOfRows()
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = delegate.getData(at: indexPath)
        cell.textLabel?.font = UIFont(name: "Menlo-Bold", size: 20)
        cell.textLabel?.textColor = Constants.darkColour
        cell.selectionStyle = .none
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate.itemSelected(at: indexPath)
    }
}
