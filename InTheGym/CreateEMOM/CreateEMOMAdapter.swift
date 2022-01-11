//
//  CreateEMOMAdapter.swift
//  InTheGym
//
//  Created by Findlay Wood on 15/09/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class CreateEMOMAdapter: NSObject {
    
    // MARK: - Publishers
    var rowTapped = PassthroughSubject<IndexPath,Never>()
    
}

extension CreateEMOMAdapter: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        rowTapped.send(indexPath)
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
}
