//
//  CommentSectionAdapter.swift
//  InTheGym
//
//  Created by Findlay Wood on 17/12/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class CommentSectionAdapter: NSObject {
    
    
}
extension CommentSectionAdapter: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .systemGray5
        return view
    }
}
