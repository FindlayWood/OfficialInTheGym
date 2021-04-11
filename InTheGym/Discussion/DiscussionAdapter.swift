//
//  DiscussionAdapter.swift
//  InTheGym
//
//  Created by Findlay Wood on 25/03/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class DiscussionAdapter: NSObject {
    
    var delegate : DiscussionProtocol!
    
    init(delegate:DiscussionProtocol){
        self.delegate = delegate
    }
    
}
extension DiscussionAdapter: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return delegate.retreiveNumberOfItems()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rowModel:PostProtocol!
        if indexPath.row == 0{
            rowModel = delegate.getOriginalPost()
        } else {
            rowModel = delegate.getData(at: indexPath)
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier(for: rowModel), for: indexPath)
        if var cell = cell as? DiscussionCellConfigurable{
            cell.setup(rowViewModel: rowModel)
            cell.delegate = self.delegate as! DiscussionTapProtocol
        }
        return cell
    }
    
    
    private func cellIdentifier(for rowModel:PostProtocol) -> String{
        switch rowModel {
        case is DiscussionPost:
            return OriginalPostTableViewCell.cellIdentifier()
        case is DiscussionCreatedWorkout:
            return OriginalCreatedWorkoutTableViewCell.cellIdentifier()
        case is DiscussionCompletedWorkout:
            return OriginalCompletedWorkoutTableViewCell.cellIdentifier()
        case is DiscussionReply:
            return ReplyTableViewCell.cellIdentifier()
        default:
            return "error with row \(rowModel)"
        }
    }
    
}
