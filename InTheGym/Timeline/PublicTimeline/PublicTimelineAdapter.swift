//
//  PublicTimelineAdapter.swift
//  InTheGym
//
//  Created by Findlay Wood on 23/03/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit


class PublicTimelineAdapter:NSObject{
    
    var delegate:PublicTimelineProtocol!
    
    init(delegate:PublicTimelineProtocol){
        self.delegate = delegate
    }
    
}

extension PublicTimelineAdapter: UITableViewDelegate, UITableViewDataSource  {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = Constants.darkColour
        return view
    }
    
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return delegate.retreiveNumberOfSections()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate.itemSelected(at: indexPath)
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
