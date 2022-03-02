//
//  GroupHomePageAdapter.swift
//  InTheGym
//
//  Created by Findlay Wood on 12/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class GroupHomePageAdapter: NSObject {
    var delegate: GroupHomePageProtocol
    init(delegate: GroupHomePageProtocol) {
        self.delegate = delegate
    }
    var lastContentOffset: CGFloat = 150
    var headerView: StretchyTableHeaderView!
}
extension GroupHomePageAdapter: UITableViewDelegate {
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 2
//    }
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if section == 0 {
//            return 3
//        } else {
//            if delegate.postsLoaded() {
//                return delegate.numberOfPosts()
//            } else {
//                return 1
//            }
//        }
//    }
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        if indexPath.section == 0 {
//            if indexPath.row == 0 {
//                let cell = UITableViewCell()
//                cell.textLabel?.text = delegate.getGroupInfo().username
//                cell.textLabel?.font = Constants.font
//                cell.selectionStyle = .none
//                return cell
//            } else if indexPath.row == 1 {
//                if delegate.leaderLoaded() {
//                    let cell = tableView.dequeueReusableCell(withIdentifier: UserTableViewCell.cellID, for: indexPath) as! UserTableViewCell
//                    let leader = delegate.getGroupLeader()
//                    cell.configureCell(with: leader)
//                    return cell
//                } else {
//                    let cell = tableView.dequeueReusableCell(withIdentifier: LoadingTableViewCell.cellID, for: indexPath) as! LoadingTableViewCell
//                    return cell
//                }
//            } else {
//                let cell = tableView.dequeueReusableCell(withIdentifier: GroupHomePageInfoTableViewCell.cellID, for: indexPath) as! GroupHomePageInfoTableViewCell
//                cell.delegate = delegate
//                cell.configureForLeader(delegate.isCurrentUserLeader())
//                return cell
//            }
//        } else {
//            if delegate.postsLoaded() {
//                let rowModel = delegate.getPostData(at: indexPath)
//                let cell = tableView.dequeueReusableCell(withIdentifier: PostTableViewCell.cellID, for: indexPath) as! PostTableViewCell
//                cell.configure(with: rowModel)
//                cell.delegate = delegate
//                return cell
//            } else {
//                let cell = tableView.dequeueReusableCell(withIdentifier: LoadingTableViewCell.cellID, for: indexPath) as! LoadingTableViewCell
//                return cell
//            }
//        }
//    }
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if indexPath.section == 2 {
//            if delegate.isCurrentUserLeader() {
//                return 160
//            } else {
//                return 110
//            }
//        } else {
//            return UITableView.automaticDimension
//        }
//        if indexPath == IndexPath(row: 1, section: 0) {
//            if delegate.leaderLoaded() {
//                return 80
//            } else {
//                return 60
//            }
//        } else if indexPath == IndexPath(row: 2, section: 0) {
//            if delegate.isCurrentUserLeader() {
//                return 160
//            } else {
//                return 110
//            }
//            //return 160
//            //return UITableView.automaticDimension
//        } else if indexPath.section == 1 {
//            if delegate.postsLoaded() {
//                return UITableView.automaticDimension
//            } else {
//                return 60
//            }
//        } else {
//            return UITableView.automaticDimension
//        }
//    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            delegate.leaderSelected()
        } else if indexPath.section == 3 {
            delegate.postSelected(at: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            return 15
        } else if section == 3 {
            return 25
        } else {
            return 0
        }
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 {
            let label = UILabel()
            label.text = "Created By"
            label.font = .boldSystemFont(ofSize: 12)
            label.backgroundColor = .white
            label.textAlignment = .center
            label.textColor = .lightGray
            return label
        } else if section == 3 {
            let label = UILabel()
            label.text = "POSTS"
            label.font = .boldSystemFont(ofSize: 20)
            label.backgroundColor = .white
            label.textAlignment = .center
            label.textColor = .darkColour
            return label
        } else {
            return nil
        }
    }
        
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        headerView.scrollViewDidScroll(scrollView: scrollView)
        if lastContentOffset < scrollView.contentOffset.y {
            delegate.scrolledTo(headerInView: false)
        } else if lastContentOffset > scrollView.contentOffset.y {
            delegate.scrolledTo(headerInView: true)
        }
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
