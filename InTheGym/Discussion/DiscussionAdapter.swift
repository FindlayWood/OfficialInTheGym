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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return delegate.retreiveNumberOfSections()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return delegate.retreiveNumberOfItems()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rowModel:PostProtocol!
        if indexPath.section == 0 {
            rowModel = delegate.getOriginalPost()
        } else {
            rowModel = delegate.getData(at: indexPath)
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier(for: rowModel), for: indexPath)
        if var cell = cell as? DiscussionCellConfigurable {
            cell.setup(rowViewModel: rowModel)
            cell.delegate = self.delegate as? DiscussionTapProtocol
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate.itemSelected(at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .systemGray5
        return view
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
        case is DiscussionReplyPlusWorkout:
            return DiscussionReplyAttachedWorkout.cellIdentifier()
        default:
            return "error with row \(rowModel)"
        }
    }
    
}
