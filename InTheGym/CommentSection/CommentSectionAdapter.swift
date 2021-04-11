//
//  CommentSectionAdapter.swift
//  InTheGym
//
//  Created by Findlay Wood on 17/03/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class CommenstSectionAdapter:NSObject{
    
    var delegate:CommentSectionProtocol!
    
    init(delegate:CommentSectionProtocol) {
        self.delegate = delegate
    }
    
}

extension CommenstSectionAdapter: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return delegate.retreiveNumberOfItems()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    
}
