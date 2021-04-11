//
//  GroupPageAdapter.swift
//  InTheGym
//
//  Created by Findlay Wood on 07/04/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit
import EmptyDataSet_Swift

class GroupPageAdapter: NSObject {
    
    var delegate : GroupPageProtocol!
    
    init(delegate:GroupPageProtocol){
        self.delegate = delegate
    }

}

extension GroupPageAdapter: UITableViewDelegate, UITableViewDataSource , EmptyDataSetSource, EmptyDataSetDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return delegate.retreiveNumberOfPosts()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rowModel = delegate.getPostData(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier(for: rowModel), for: indexPath)
        if var cell = cell as? CellConfiguarable{
            cell.setup(rowViewModel: rowModel)
            cell.delegate = self.delegate as? TimelineTapProtocol
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate.postSelected(at: indexPath)
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = "POSTS"
        label.font = .boldSystemFont(ofSize: 20)
        //label.font = .preferredFont(forTextStyle: UIFont.TextStyle(rawValue: "Menlo Bold"))
        label.backgroundColor = .white
        label.textAlignment = .center
        label.textColor = Constants.darkColour
        return label
    }
    
    // emptydataset functions
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = "No Posts"
        let attrs = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .headline)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = "This group has no posts. Add posts and workouts by tapping the plus button in the top right."
        let attrs = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .body)]
        return NSAttributedString(string: str, attributes: attrs)
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

extension GroupPageAdapter: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GroupMemberCollectionViewCell", for: indexPath) as! GroupMemberCollectionViewCell
        let member = delegate.getMemberData(at: indexPath)
        cell.setup(with: member)
        if indexPath.item == 0{
            cell.makeLeader()
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return delegate.retreiveNumberOfMembers()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.delegate.memberSelected(at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 70, height: 90)
    }
    
}
