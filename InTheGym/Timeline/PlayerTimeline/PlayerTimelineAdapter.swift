//
//  PlayerTimelineAdapter.swift
//  InTheGym
//
//  Created by Findlay Wood on 15/03/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class PlayerTimelineAdapter:NSObject{
    
    var delegate:PlayerTimelineProtocol
    
    init(delegate:PlayerTimelineProtocol){
        self.delegate = delegate
    }
    
}

extension PlayerTimelineAdapter: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return delegate.retreiveNumberOfItems()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rowModel = delegate.getData(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier(for: rowModel), for: indexPath)
        if var cell = cell as? CellConfiguarable{
            cell.setup(rowViewModel: rowModel)
            cell.delegate = self.delegate as? TimelineTapProtocol
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate.itemSelected(at: indexPath)
    }
    
    private func cellIdentifier(for rowModel:PostProtocol) -> String{
        switch rowModel{
        case is TimelinePostModel:
            return TimelinePostTableViewCell.cellIdentifier()
        case is TimelineCreatedWorkoutModel:
            return TimelineCreatedWorkoutTableViewCell.cellIdentifier()
        case is TimelineCompletedWorkoutModel:
            return TimelineCompletedWorkoutTableViewCell.cellIdentifier()
        case is TimelineActivityModel:
            return TimelineActivityTableViewCell.cellIdentifier()
        default:
            return "Unexpected row model type \(rowModel)"
        }
    }
}
